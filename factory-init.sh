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
#   ./factory-init.sh help
#
# Execute sempre a partir de FACTORY_ROOT/.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
FACTORY_VERSION="1.1.0"
FACTORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="${FACTORY_PROJECTS_DIR:-$HOME/Dev/Projects}"
TEMPLATES_DIR="$FACTORY_ROOT/docs/templates"
AGENTS_DIR="$FACTORY_ROOT/docs/agents"
GLOBAL_AGENTS_DIR="$HOME/.claude/agents"
GLOBAL_COMMANDS_DIR="$HOME/.claude/commands"
CONFIG_FILE=".factory"

# ---------------------------------------------------------------------------
# Utilitários
# ---------------------------------------------------------------------------
info()    { echo "  [info]    $*"; }
success() { echo "  [ok]      $*"; }
warn()    { echo "  [aviso]   $*"; }
error()   { echo "  [erro]    $*" >&2; exit 1; }
divider() { printf "\n%s\n\n" "──────────────────────────────────────────────"; }

require_templates() {
  [ -d "$TEMPLATES_DIR" ] || error "Templates não encontrados em $TEMPLATES_DIR"
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

  success "Comando /factory-init criado em $commands_dir/"
}

# ---------------------------------------------------------------------------
# Instala agentes globalmente
# ---------------------------------------------------------------------------
cmd_agents() {
  info "Instalando agentes em $GLOBAL_AGENTS_DIR ..."
  mkdir -p "$GLOBAL_AGENTS_DIR"
  local count=0
  for agent in "$AGENTS_DIR"/*.md; do
    local filename
    filename=$(basename "$agent")
    [ "$filename" = "README.md" ] && continue
    [ -f "$GLOBAL_AGENTS_DIR/$filename" ] && warn "Sobrescrevendo: $filename"
    cp "$agent" "$GLOBAL_AGENTS_DIR/$filename"
    success "Instalado: $filename"
    ((count++)) || true
  done
  divider
  success "$count agentes instalados em $GLOBAL_AGENTS_DIR"
  info "Verifique com: claude agents"
}

# ---------------------------------------------------------------------------
# Monta estrutura Factory/<projeto>/ e cria CLAUDE.md e comando em src
# ---------------------------------------------------------------------------
_setup_factory_project() {
  local project_name="$1" src_path="$2" today="$3"
  local factory_dir="$FACTORY_ROOT/$project_name"

  mkdir -p "$factory_dir/docs"
  cp -r "$TEMPLATES_DIR/." "$factory_dir/docs/"
  success "Estrutura docs/ criada em Factory/$project_name/"

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
  [ -n "$project_name" ] || error "Informe o nome: factory-init.sh new <nome>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path="$PROJECTS_DIR/$project_name"
  local today
  today=$(date +%Y-%m-%d)

  [ -d "$factory_dir" ] && error "Já existe em Factory: $factory_dir"
  [ -d "$src_path"    ] && error "Já existe em Projects: $src_path"

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

  [ -n "$project_name" ] || error "Informe o nome: factory-init.sh adopt <nome> [--mode=full|coexist]"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path="$PROJECTS_DIR/$project_name"
  local today
  today=$(date +%Y-%m-%d)

  [ -d "$src_path" ] || error "Projeto não encontrado em $src_path"
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
  [ -n "$project_name" ] || error "Informe o nome: factory-init.sh add-command <nome>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path
  src_path=$(config_get "$factory_dir" "src_path") || \
    error "Projeto '$project_name' não encontrado. Execute 'factory-init.sh list'."

  [ -d "$src_path" ] || error "Código não encontrado: $src_path"

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
  [ -n "$project_name" ] || error "Informe o nome: factory-init.sh work <nome>"

  local factory_dir="$FACTORY_ROOT/$project_name"
  local src_path
  src_path=$(config_get "$factory_dir" "src_path") || \
    error "Projeto '$project_name' não encontrado. Execute 'factory-init.sh list'."

  [ -d "$src_path" ] || error "Código não encontrado: $src_path"

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
      echo "     @arquiteto-senior Leia docs/INDEX.md e docs/GUIDE.md."
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
  echo "  factory-init.sh — gerenciador de projetos Factory"
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
  echo "    help                           Esta mensagem"
  echo ""
  echo "  Variáveis de ambiente:"
  echo "    FACTORY_ROOT          Raiz da Factory (padrão: diretório do script)"
  echo "    FACTORY_PROJECTS_DIR  Onde ficam os projetos (padrão: ~/Dev/Projects)"
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
  help|*)      cmd_help ;;
esac
