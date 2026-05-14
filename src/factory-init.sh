#!/usr/bin/env bash
# =============================================================================
# factory-init.sh
# Gerenciador de projetos Factory.
#
# Código-fonte vive em PROJECTS_DIR/<projeto>/
# Documentação e config vivem em FACTORY_ROOT/<projeto>/
# A ponte entre os dois é /add-dir dentro da sessão Claude Code.
#
# Uso:
#   ./factory-init.sh agents                        instala agentes globalmente
#   ./factory-init.sh new     <nome>                novo projeto do zero
#   ./factory-init.sh adopt   <nome> [--mode=full|coexist]  projeto existente
#   ./factory-init.sh work    <nome>                imprime o comando de sessão
#   ./factory-init.sh list                          lista projetos registrados
#   ./factory-init.sh shell-setup                   gera função shell para .bashrc/.zshrc
#   ./factory-init.sh update [--version=X.Y.Z] [--dry-run]  atualiza arquivos do framework
#   ./factory-init.sh sync   <nome> [--dry-run]  propaga mudanças de templates para projeto
#   ./factory-init.sh help
#
# Execute sempre a partir de FACTORY_ROOT/.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
FACTORY_VERSION="1.3.0"
FACTORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="${FACTORY_PROJECTS_DIR:-$HOME/Dev/Projects}"
TEMPLATES_DIR="$FACTORY_ROOT/docs/templates"
AGENTS_DIR="$FACTORY_ROOT/docs/agents"
GLOBAL_AGENTS_DIR="$HOME/.claude/agents"
# shellcheck disable=SC2034
GLOBAL_COMMANDS_DIR="$HOME/.claude/commands"
# GLOBAL_COMMANDS_DIR: reserved for future global Claude Code commands (unused in v1.3.0)
CONFIG_FILE=".factory"

# ---------------------------------------------------------------------------
# Localization
# Load locale file if present; fall back to English defaults.
# ---------------------------------------------------------------------------
LOCALE_DIR="$FACTORY_ROOT/locales"
FACTORY_LANG="${FACTORY_LANG:-en}"
LOCALE_FILE="$LOCALE_DIR/${FACTORY_LANG}.env"

if [ -f "$LOCALE_FILE" ]; then
  # shellcheck source=/dev/null
  set -a; . "$LOCALE_FILE"; set +a
else
  # English defaults (hardcoded fallback)
  i18n_label_info="info"
  i18n_label_ok="ok"
  i18n_label_warn="warn"
  i18n_label_error="error"
  i18n_error_not_found="Templates not found in"
  i18n_error_config_not_found="Project not found"
  i18n_error_src_not_found="Source code not found"
  i18n_error_version="Could not determine version"
  i18n_error_network="Failed to fetch from network"
  i18n_error_github="GitHub token or gh CLI required for private repositories"
fi

# ---------------------------------------------------------------------------
# Utilitários
# ---------------------------------------------------------------------------
info()    { echo "  [$i18n_label_info]    $*"; }
success() { echo "  [$i18n_label_ok]      $*"; }
warn()    { echo "  [$i18n_label_warn]   $*"; }
error()   { echo "  [$i18n_label_error]    $*" >&2; exit 1; }
divider() { printf "\n%s\n\n" "$i18n_divider_char"; }

require_templates() {
  [ -d "$TEMPLATES_DIR" ] || error "$i18n_error_not_found $TEMPLATES_DIR"
}

_version_cmp() {
  local v1="$1" v2="$2"
  local -a a1 a2
  IFS='.' read -ra a1 <<< "$v1"
  IFS='.' read -ra a2 <<< "$v2"
  for i in 0 1 2; do
    local n1="${a1[i]:-0}" n2="${a2[i]:-0}"
    ((n1 > n2)) && return 1
    ((n1 < n2)) && return 2
  done
  return 0
}

_is_framework_file() {
  local f="$1"
  case "$f" in
    factory-init.sh|FACTORY-GUIDE.md|CLAUDE.md|.gitignore) return 0 ;;
    docs/agents/*.md) return 0 ;;
    docs/templates/*) return 0 ;;
  esac
  return 1
}

_fetch_latest_version() {
  local script_content version raw_url api_url
  local -a curl_args=(-fsSL)

  # Repositório privado requer autenticação — GitHub token ou gh CLI
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl_args+=(-H "Authorization: token $GITHUB_TOKEN")
    raw_url="https://raw.githubusercontent.com/fcjbispo/MyFactory/master/factory-init.sh"
    script_content=$(curl "${curl_args[@]}" "$raw_url" 2>/dev/null) || \
      error "$i18n_error_network. Check your connection or GITHUB_TOKEN."
  elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    api_url="repos/fcjbispo/MyFactory/contents/factory-init.sh?ref=master"
    script_content=$(gh api "$api_url" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null) || \
      error "$i18n_error_network via gh CLI."
  else
    error "$i18n_error_github"
  fi

  version=$(echo "$script_content" | sed -n 's/^FACTORY_VERSION="\([^"]*\)"/\1/p')
  [ -n "$version" ] || error "$i18n_error_version"
  REMOTE_TAG="v${version}"
  REMOTE_TARBALL_URL="https://raw.githubusercontent.com/fcjbispo/MyFactory/master/factory-${version}.tar.gz"
}

_fetch_specific_release() {
  local target_ver="$1"
  REMOTE_TAG="v${target_ver}"
  REMOTE_TARBALL_URL="https://github.com/fcjbispo/MyFactory/releases/download/${REMOTE_TAG}/factory-${target_ver}.tar.gz"
  local -a curl_args=(-fsSLI)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl_args+=(-H "Authorization: token $GITHUB_TOKEN")
  elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    curl_args+=(-H "Authorization: token $(gh auth token 2>/dev/null)")
  fi
  curl "${curl_args[@]}" "$REMOTE_TARBALL_URL" >/dev/null 2>&1 || \
    error "Release ${REMOTE_TAG} não encontrado em github.com/fcjbispo/MyFactory"
}

config_get() {
  local project_dir="$1" key="$2"
  local config="$project_dir/$CONFIG_FILE"
  [ -f "$config" ] || return 1
  grep "^${key}=" "$config" | cut -d'=' -f2-
}

config_set() {
  local project_dir="$1" key="$2" value="$3"
  local config="$project_dir/$CONFIG_FILE"
  touch "$config"
  if grep -q "^${key}=" "$config" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$config" 2>/dev/null || \
    sed -i '' "s|^${key}=.*|${key}=${value}|" "$config"
  else
    echo "${key}=${value}" >> "$config"
  fi
}

# ---------------------------------------------------------------------------
# Cria o comando /factory-init dentro do projeto
# Permite usar /factory-init dentro do Claude Code para
# carregar os docs da Factory sem precisar lembrar o caminho
# ---------------------------------------------------------------------------
_create_project_command() {
  local project_name="$1"
  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path="$2"
  local commands_dir="$src_path/.claude/commands"

  mkdir -p "$commands_dir"

  cat > "$commands_dir/factory-init.md" << EOF
Adicione a documentação Factory ao contexto desta sessão executando:

/add-dir $factory_dir/docs

Após o comando ser aceito, leia os seguintes arquivos em sequência:
1. docs/INDEX.md — mapa da documentação e responsabilidades
2. docs/context/active.md — foco atual e próximos passos (se existir)
3. docs/context/progress.md — status do projeto (se existir)
4. docs/architecture/overview.md — visão do sistema

Confirme que os arquivos foram lidos e informe o estado atual do projeto
com base no que encontrou.
EOF

  success "Command /factory-init created in $commands_dir/"
}

# ---------------------------------------------------------------------------
# Instala agentes globalmente
# ---------------------------------------------------------------------------
cmd_agents() {
  info "$i18n_info_installing $GLOBAL_AGENTS_DIR ..."
  mkdir -p "$GLOBAL_AGENTS_DIR"
  local count=0
  for agent in "$AGENTS_DIR"/*.md; do
    local filename
    filename=$(basename "$agent")
    [ "$filename" = "README.md" ] && continue
    [ -f "$GLOBAL_AGENTS_DIR/$filename" ] && warn "$i18n_warn_overwriting: $filename"
    cp "$agent" "$GLOBAL_AGENTS_DIR/$filename"
    success "Instalado: $filename"
    ((count++)) || true
  done
  divider
  success "$count $i18n_success_installed in $GLOBAL_AGENTS_DIR"
  info "Check with: claude agents"
}

# ---------------------------------------------------------------------------
# Monta estrutura Factory/<projeto>/ e cria CLAUDE.md e comando em src
# ---------------------------------------------------------------------------
_setup_factory_project() {
  local project_name="$1" src_path="$2" today="$3"
  local factory_dir="$FACTORY_ROOT/$project_name"

  mkdir -p "$factory_dir/docs"
  cp -r "$TEMPLATES_DIR/." "$factory_dir/docs/"
  success "docs/ structure created in Factory/$project_name/"

  # Cria pasta docs/context/ que não existe nos templates base
  mkdir -p "$factory_dir/docs/context"

  sed -i "s/\[NOME DO PROJETO\]/$project_name/g" "$factory_dir/docs/INDEX.md" 2>/dev/null || \
    sed -i '' "s/\[NOME DO PROJETO\]/$project_name/g" "$factory_dir/docs/INDEX.md"
  sed -i "s/YYYY-MM-DD/$today/g" "$factory_dir/docs/INDEX.md" 2>/dev/null || \
    sed -i '' "s/YYYY-MM-DD/$today/g" "$factory_dir/docs/INDEX.md"

  config_set "$factory_dir" "name"     "$project_name"
  config_set "$factory_dir" "src_path" "$src_path"
  config_set "$factory_dir" "created"  "$today"
  success "Config salva em Factory/$project_name/.factory"

  cat > "$src_path/CLAUDE.md" << EOF
# $project_name

## Documentação
A documentação deste projeto é gerenciada pelo framework Factory.
Localização: $factory_dir/docs/

## Como carregar o contexto Factory nesta sessão
Execute dentro do Claude Code:
  /factory-init

Ou manualmente:
  /add-dir $factory_dir/docs

Após carregar, leia docs/INDEX.md e docs/context/active.md.

## Padrões deste projeto
- Documentos: Markdown com frontmatter YAML
- Commits: Conventional Commits
- Branches: feat/, fix/, chore/, docs/
EOF
  success "CLAUDE.md criado em $src_path/"

  _create_project_command "$project_name" "$src_path"
}

# ---------------------------------------------------------------------------
# Novo projeto do zero
# ---------------------------------------------------------------------------
cmd_new() {
  local project_name="${1:-}"
  [ -n "$project_name" ] || error "Usage: factory-init.sh new <name>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path="$PROJECTS_DIR/$project_name"
  local today
  today=$(date +%Y-%m-%d)

  [ -d "$factory_dir" ] && error "Already exists in Factory: $factory_dir"
  [ -d "$src_path"    ] && error "Already exists in Projects: $src_path"

  require_templates

  info "Criando projeto: $project_name"
  info "  Factory : $factory_dir"
  info "  Código  : $src_path"

  mkdir -p "$src_path"
  _setup_factory_project "$project_name" "$src_path" "$today"

  divider
  success "Projeto '$project_name' criado."
  _print_next_steps "$project_name" "$src_path" "$factory_dir" "new"
}

# ---------------------------------------------------------------------------
# Integra projeto existente
# ---------------------------------------------------------------------------
cmd_adopt() {
  local project_name="${1:-}"
  local mode="full"

  for arg in "$@"; do
    case $arg in
      --mode=full)    mode="full"    ;;
      --mode=coexist) mode="coexist" ;;
    esac
  done

  [ -n "$project_name" ] || error "Usage: factory-init.sh adopt <name> [--mode=full|coexist]"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path="$PROJECTS_DIR/$project_name"
  local today
  today=$(date +%Y-%m-%d)

  [ -d "$src_path" ] || error "$i18n_error_src_not_found: $src_path"
  require_templates

  info "Integrando: $project_name  |  modo: $mode"

  mkdir -p "$factory_dir"

  case $mode in
    full)
      if [ -d "$src_path/docs" ]; then
        cp -r "$src_path/docs" "$factory_dir/docs-legado"
        warn "docs/ existente copiado para Factory/$project_name/docs-legado/"
      fi

      _setup_factory_project "$project_name" "$src_path" "$today"

      cat >> "$src_path/CLAUDE.md" << EOF

## Documentação legada
Arquivada em: $factory_dir/docs-legado/
Consulte para contexto histórico. Toda nova documentação vai em docs/ (via /factory-init).
EOF
      config_set "$factory_dir" "mode" "full"
      divider
      success "Projeto '$project_name' adotado (migração completa)."
      _print_next_steps "$project_name" "$src_path" "$factory_dir" "full"
      ;;

    coexist)
      _setup_factory_project "$project_name" "$src_path" "$today"
      config_set "$factory_dir" "mode" "coexist"

      cat >> "$src_path/CLAUDE.md" << EOF

## Modo convivência
- Documentação nova   → docs/ (via /factory-init)
- Documentação legada → $src_path/docs/ (somente leitura para contexto)

Em caso de conflito, Factory docs/ prevalece.
Para encerrar convivência: factory-init.sh adopt $project_name --mode=full
EOF
      divider
      success "Projeto '$project_name' adotado (convivência)."
      _print_next_steps "$project_name" "$src_path" "$factory_dir" "coexist"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Adiciona o comando /factory-init a um projeto já existente
# sem precisar recriar toda a estrutura
# ---------------------------------------------------------------------------
cmd_add_command() {
  local project_name="${1:-}"
  [ -n "$project_name" ] || error "Usage: factory-init.sh add-command <name>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path
  src_path=$(config_get "$factory_dir" "src_path") || \
    error "Project not found. Run 'factory-init.sh list'."

  [ -d "$src_path" ] || error "$i18n_error_src_not_found: $src_path"

  _create_project_command "$project_name" "$src_path"
  divider
  success "Comando /factory-init adicionado a '$project_name'."
  echo "  Use dentro do Claude Code: /factory-init"
  echo ""
}

# ---------------------------------------------------------------------------
# Imprime o comando de sessão
# ---------------------------------------------------------------------------
cmd_work() {
  local project_name="${1:-}"
  [ -n "$project_name" ] || error "Usage: factory-init.sh work <name>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path
  src_path=$(config_get "$factory_dir" "src_path") || \
    error "Project not found. Run 'factory-init.sh list'."

  [ -d "$src_path" ] || error "$i18n_error_src_not_found: $src_path"

  echo ""
  echo "  Inicie a sessão na pasta do projeto:"
  echo ""
  echo "  cd $src_path"
  echo "  claude   (ou o comando do seu provedor)"
  echo ""
  echo "  Dentro do Claude Code, execute:"
  echo "  /factory-init"
  echo ""
}

# ---------------------------------------------------------------------------
# Lista projetos registrados
# ---------------------------------------------------------------------------
cmd_list() {
  echo ""
  printf "  %-25s %-10s %-12s %s\n" "PROJETO" "MODO" "CRIADO" "CÓDIGO"
  printf "  %-25s %-10s %-12s %s\n" "-------" "----" "------" "------"

  local found=0
  for factory_dir in "$FACTORY_ROOT"/*/; do
    [ -f "$factory_dir/$CONFIG_FILE" ] || continue
    local name mode created src_path
    name=$(    config_get "$factory_dir" "name"     2>/dev/null || echo "—")
    mode=$(    config_get "$factory_dir" "mode"     2>/dev/null || echo "full")
    created=$( config_get "$factory_dir" "created"  2>/dev/null || echo "—")
    src_path=$(config_get "$factory_dir" "src_path" 2>/dev/null || echo "—")
    printf "  %-25s %-10s %-12s %s\n" "$name" "$mode" "$created" "$src_path"
    ((found++)) || true
  done

  [ $found -eq 0 ] && echo "  Nenhum projeto registrado ainda."
  echo ""
}

# ---------------------------------------------------------------------------
# Gera bloco de função shell para .bashrc / .zshrc
# ---------------------------------------------------------------------------
cmd_shell_setup() {
  cat << SHELL_BLOCK

# ── Factory shell integration ─────────────────────────────────────────────
# Cole este bloco no seu ~/.bashrc ou ~/.zshrc e recarregue:
#   source ~/.bashrc   (ou ~/.zshrc)

export FACTORY_ROOT="$FACTORY_ROOT"
export FACTORY_PROJECTS_DIR="$PROJECTS_DIR"

factory() {
  local cmd="\${1:-help}"
  case "\$cmd" in
    work)
      local project="\${2:-}"
      [ -n "\$project" ] || { echo "Uso: factory work <projeto>"; return 1; }
      local factory_dir="\$FACTORY_ROOT/\$project"
      local config="\$factory_dir/.factory"
      [ -f "\$config" ] || { echo "Projeto '\$project' não encontrado."; return 1; }
      local src_path
      src_path=\$(grep "^src_path=" "\$config" | cut -d'=' -f2-)
      [ -d "\$src_path" ] || { echo "Código não encontrado: \$src_path"; return 1; }
      echo ""
      echo "  projeto : \$project"
      echo "  código  : \$src_path"
      echo ""
      echo "  Dentro do Claude Code execute: /factory-init"
      echo ""
      cd "\$src_path"
      ;;
    *)
      "\$FACTORY_ROOT/factory-init.sh" "\$@"
      ;;
  esac
}
# ─────────────────────────────────────────────────────────────────────────
SHELL_BLOCK
}

# ---------------------------------------------------------------------------
# Atualiza arquivos do framework a partir de GitHub Release
# ---------------------------------------------------------------------------
cmd_update() {
  local target_version="" dry_run=false

  for arg in "$@"; do
    case $arg in
      --version=*) target_version="${arg#--version=}" ;;
      --dry-run)    dry_run=true ;;
    esac
  done

  command -v curl >/dev/null 2>&1 || error "curl is required for update"
  command -v tar  >/dev/null 2>&1 || error "tar is required for update"

  info "Versão instalada: $FACTORY_VERSION"

  if [ -n "$target_version" ]; then
    _fetch_specific_release "$target_version"
  else
    _fetch_latest_version
  fi

  local remote_ver="${REMOTE_TAG#v}"

  if _version_cmp "$FACTORY_VERSION" "$remote_ver"; then
    success "Factory v$FACTORY_VERSION já está atualizado."
    exit 0
  fi

  local is_downgrade=false
  if _version_cmp "$FACTORY_VERSION" "$remote_ver"; then :; else
    local cmp_result=$?
    [ "$cmp_result" -eq 1 ] && is_downgrade=true
  fi

  if $is_downgrade; then
    warn "Versão solicitada ($remote_ver) é anterior à instalada ($FACTORY_VERSION)"
    echo -n "  Continuar com downgrade? (s/N) "; read -r answer
    [ "$answer" = "s" ] || [ "$answer" = "S" ] || { info "Downgrade cancelado."; exit 0; }
  fi

  info "Baixando Factory v$remote_ver..."
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  local tarball_name="factory-${remote_ver}.tar.gz"
  local -a download_args=(-fsSL)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    download_args+=(-H "Authorization: token $GITHUB_TOKEN")
    curl "${download_args[@]}" "$REMOTE_TARBALL_URL" -o "$tmp_dir/$tarball_name" || \
      error "Failed to download $REMOTE_TARBALL_URL"
  elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    curl "${download_args[@]}" -H "Authorization: token $(gh auth token 2>/dev/null)" \
      "$REMOTE_TARBALL_URL" -o "$tmp_dir/$tarball_name" || \
      error "Failed to download $REMOTE_TARBALL_URL"
  else
    curl "${download_args[@]}" "$REMOTE_TARBALL_URL" -o "$tmp_dir/$tarball_name" || \
      error "Failed to download $REMOTE_TARBALL_URL"
  fi

  tar xzf "$tmp_dir/$tarball_name" -C "$tmp_dir" --no-same-owner --no-same-permissions || \
    error "Failed to extract tarball"

  local extract_dir="$tmp_dir/factory-${remote_ver}"
  [ -d "$extract_dir" ] || error "Unexpected tarball structure"

  while IFS= read -r fpath; do
    local real_path
    real_path=$(realpath "$fpath")
    [[ "$real_path" == "$tmp_dir/"* ]] || \
      { rm -rf "$tmp_dir"; error "Path traversal detected in tarball — aborting."; }
  done < <(cd "$extract_dir" && find . -type l -o -type f)

  info "Comparando arquivos..."
  local modified=0 new_files=0 unchanged=0

  while IFS= read -r relpath; do
    [ -z "$relpath" ] && continue
    _is_framework_file "$relpath" || continue

    if [ -f "$FACTORY_ROOT/$relpath" ]; then
      if diff -q "$FACTORY_ROOT/$relpath" "$extract_dir/$relpath" >/dev/null 2>&1; then
        echo "  INALTERADO  $relpath"
        ((unchanged++)) || true
      else
        echo "  MODIFICADO  $relpath"
        ((modified++)) || true
      fi
    else
      echo "  NOVO        $relpath"
      ((new_files++)) || true
    fi
  done < <(cd "$extract_dir" && find . -type f | sed 's|^\./||' | sort)

  echo ""
  info "$modified modificados, $new_files novos, $unchanged inalterados"

  if $dry_run; then
    info "Modo dry-run — nenhuma alteração aplicada."
    exit 0
  fi

  echo ""
  echo -n "  Aplicar atualização v$FACTORY_VERSION → v$remote_ver? (s/N) "; read -r answer
  [ "$answer" = "s" ] || [ "$answer" = "S" ] || { info "Atualização cancelada."; exit 0; }

  local applied=0 failed=0
  while IFS= read -r relpath; do
    [ -z "$relpath" ] && continue
    _is_framework_file "$relpath" || continue

    if [ -f "$FACTORY_ROOT/$relpath" ]; then
      if ! diff -q "$FACTORY_ROOT/$relpath" "$extract_dir/$relpath" >/dev/null 2>&1; then
        if cp "$extract_dir/$relpath" "$FACTORY_ROOT/$relpath"; then
          success "Atualizado: $relpath"
          ((applied++)) || true
        else
          warn "Falha ao atualizar: $relpath"
          ((failed++)) || true
        fi
      fi
    else
      mkdir -p "$(dirname "$FACTORY_ROOT/$relpath")"
      if cp "$extract_dir/$relpath" "$FACTORY_ROOT/$relpath"; then
        success "Novo: $relpath"
        ((applied++)) || true
      else
        warn "Falha ao criar: $relpath"
        ((failed++)) || true
      fi
    fi
  done < <(cd "$extract_dir" && find . -type f | sed 's|^\./||' | sort)

  echo ""
  success "$applied arquivos atualizados para v$remote_ver."
  [ "$failed" -gt 0 ] && warn "$failed arquivos falharam — execute novamente."

  if [ "$modified" -gt 0 ] || [ "$new_files" -gt 0 ]; then
    info "factory-init.sh foi atualizado. Execute novamente para usar a versão $remote_ver."
  fi
}

# ---------------------------------------------------------------------------
# Propaga mudanças de templates canônicos para projeto específico
# ---------------------------------------------------------------------------
cmd_sync() {
  local project_name="" dry_run=false

  for arg in "$@"; do
    case $arg in
      --dry-run) dry_run=true ;;
      *)         [ -z "$project_name" ] && project_name="$arg" ;;
    esac
  done

  [ -n "$project_name" ] || error "Usage: factory-init.sh sync <name> [--dry-run]"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local project_docs="$factory_dir/docs"

  [ -f "$factory_dir/$CONFIG_FILE" ] || \
    error "Project not found. Run 'factory-init.sh list'."
  [ -d "$project_docs" ] || \
    error "Projeto '$project_name' não tem diretório docs/."

  local project_name_real project_created
  project_name_real=$(config_get "$factory_dir" "name" 2>/dev/null || echo "$project_name")
  project_created=$(config_get "$factory_dir" "created" 2>/dev/null || date +%Y-%m-%d)

  require_templates

  info "Comparando templates com Factory/$project_name/docs/..."

  local modified=0 new_files=0 unchanged=0 project_specific=0

  # List template files
  while IFS= read -r relpath; do
    [ -z "$relpath" ] && continue

    if [ -f "$project_docs/$relpath" ]; then
      if diff -q "$TEMPLATES_DIR/$relpath" "$project_docs/$relpath" >/dev/null 2>&1; then
        echo "  INALTERADO  $relpath"
        ((unchanged++)) || true
      else
        echo "  MODIFICADO  $relpath"
        ((modified++)) || true
      fi
    else
      echo "  NOVO        $relpath"
      ((new_files++)) || true
    fi
  done < <(cd "$TEMPLATES_DIR" && find . -type f | sed 's|^\./||' | sort)

  # List project-specific files (not in templates)
  while IFS= read -r relpath; do
    [ -z "$relpath" ] && continue
    if [ ! -f "$TEMPLATES_DIR/$relpath" ]; then
      echo "  ESPECÍFICO  $relpath  (não será tocado)"
      ((project_specific++)) || true
    fi
  done < <(cd "$project_docs" && find . -type f | sed 's|^\./||' | sort)

  echo ""
  info "$modified modificados, $new_files novos, $unchanged inalterados, $project_specific específicos do projeto"

  if $dry_run; then
    info "Modo dry-run — nenhuma alteração aplicada."
    exit 0
  fi

  echo ""
  echo -n "  Aplicar alterações ao projeto '$project_name'? (s/N) "; read -r answer
  [ "$answer" = "s" ] || [ "$answer" = "S" ] || { info "Sincronização cancelada."; exit 0; }

  local applied=0

  while IFS= read -r relpath; do
    [ -z "$relpath" ] && continue

    if [ -f "$project_docs/$relpath" ]; then
      if ! diff -q "$TEMPLATES_DIR/$relpath" "$project_docs/$relpath" >/dev/null 2>&1; then
        cp "$TEMPLATES_DIR/$relpath" "$project_docs/$relpath"
        # Re-apply project-specific substitutions on INDEX.md
        if [ "$(basename "$relpath")" = "INDEX.md" ]; then
          local escaped_name escaped_date
          escaped_name=$(printf '%s\n' "$project_name_real" | sed 's/[&/\]/\\&/g')
          escaped_date=$(printf '%s\n' "$project_created" | sed 's/[&/\]/\\&/g')
          sed -i "s/\[NOME DO PROJETO\]/$escaped_name/g" "$project_docs/$relpath" 2>/dev/null || \
            sed -i '' "s/\[NOME DO PROJETO\]/$escaped_name/g" "$project_docs/$relpath"
          sed -i "s/YYYY-MM-DD/$escaped_date/g" "$project_docs/$relpath" 2>/dev/null || \
            sed -i '' "s/YYYY-MM-DD/$escaped_date/g" "$project_docs/$relpath"
        fi
        success "Atualizado: $relpath"
        ((applied++)) || true
      fi
    else
      mkdir -p "$(dirname "$project_docs/$relpath")"
      cp "$TEMPLATES_DIR/$relpath" "$project_docs/$relpath"
      success "Novo: $relpath"
      ((applied++)) || true
    fi
  done < <(cd "$TEMPLATES_DIR" && find . -type f | sed 's|^\./||' | sort)

  echo ""
  success "Sincronização concluída: $applied arquivos atualizados no projeto '$project_name'."
  [ "$new_files" -gt 0 ] && info "Novos templates podem requerer atualização em docs/INDEX.md do projeto."
}

# ---------------------------------------------------------------------------
# Próximos passos (helper interno)
# ---------------------------------------------------------------------------
_print_next_steps() {
  local project_name="$1" src_path="$2" factory_dir="$3" mode="$4"
  echo "  Próximos passos:"
  echo ""
  echo "  1. Adicione a função factory ao shell (uma vez por máquina):"
  echo "     ./factory-init.sh shell-setup >> ~/.zshrc && source ~/.zshrc"
  echo ""
  echo "  2. Instale os agentes globalmente (uma vez por máquina):"
  echo "     ./factory-init.sh agents"
  echo ""
  echo "  3. Inicie a sessão:"
  echo "     cd $src_path"
  echo "     claude   (ou o comando do seu provedor)"
  echo ""
  echo "  4. Dentro do Claude Code, execute:"
  echo "     /factory-init"
  echo ""

  case $mode in
    new)
      echo "  5. Em seguida:"
      echo "     @senior-architect Leia docs/INDEX.md e docs/GUIDE.md."
      echo "     Crie docs/architecture/overview.md e o primeiro ADR."
      ;;
    full)
      echo "  5. Em seguida:"
      echo "     execute prompt factory-adoption"
      echo "     (ou cole o prompt de inicialização manualmente)"
      ;;
    coexist)
      echo "  5. Em seguida:"
      echo "     execute prompt factory-adoption"
      echo "     (ou cole o prompt de inicialização manualmente)"
      ;;
  esac
  echo ""
}

# ---------------------------------------------------------------------------
# Ajuda
# ---------------------------------------------------------------------------
cmd_help() {
  echo ""
  echo "  factory-init.sh v$FACTORY_VERSION — gerenciador de projetos Factory"
  echo ""
  echo "  Comandos:"
  echo "    agents                         Instala agentes em ~/.claude/agents/"
  echo "    new     <nome>                 Cria projeto novo (código + docs)"
  echo "    adopt   <nome> --mode=full     Integra projeto existente (migração)"
  echo "    adopt   <nome> --mode=coexist  Integra projeto existente (convivência)"
  echo "    add-command <nome>             Adiciona /factory-init a projeto existente"
  echo "    work    <nome>                 Mostra como iniciar sessão no projeto"
  echo "    list                           Lista projetos registrados"
  echo "    shell-setup                    Gera bloco de função shell"
  echo "    update [--version=X.Y.Z] [--dry-run]  Atualiza arquivos do framework"
  echo "    sync   <nome> [--dry-run]     Propaga mudanças de templates para projeto"
  echo "    help                           Esta mensagem"
  echo ""
  echo "  Variáveis de ambiente:"
  echo "    FACTORY_ROOT          Raiz da Factory (padrão: diretório do script)"
  echo "    FACTORY_PROJECTS_DIR  Onde ficam os projetos (padrão: ~/Dev/Projects)"
  echo "    GITHUB_TOKEN          Token para API do GitHub (evita rate limit)"
  echo ""
}

# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------
case "${1:-help}" in
  agents)      cmd_agents ;;
  new)         cmd_new "${2:-}" ;;
  adopt)       cmd_adopt "${2:-}" "${@:3}" ;;
  add-command) cmd_add_command "${2:-}" ;;
  work)        cmd_work "${2:-}" ;;
  list)        cmd_list ;;
  shell-setup) cmd_shell_setup ;;
  update)      cmd_update "${@:2}" ;;
  sync)        cmd_sync "${2:-}" "${@:3}" ;;
  help|*)      cmd_help ;;
esac
