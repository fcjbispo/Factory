FACTORY_VERSION := $(shell sed -n 's/^FACTORY_VERSION="\([^"]*\)"/\1/p' factory-init.sh)
TARBALL          := factory-$(FACTORY_VERSION).tar.gz
STAGE_DIR        := /tmp/factory-$(FACTORY_VERSION)
GITHUB_REPO      := fcjbispo/MyFactory

.PHONY: help tarball version version-sync lint check clean tag release

help:
	@echo "Factory Framework v$(FACTORY_VERSION)"
	@echo ""
	@echo "Alvos disponíveis:"
	@echo "  help          — Mostra esta ajuda"
	@echo "  version       — Mostra versão atual"
	@echo "  tarball       — Gera tarball da versão atual"
	@echo "  version-sync  — Sincroniza versão nos docs"
	@echo "  lint          — Valida factory-init.sh"
	@echo "  check         — Alias para lint"
	@echo "  clean         — Remove tarballs gerados"
	@echo "  tag           — Cria git tag da versão"
	@echo "  release       — Gera tarball + tag (tudo)"
	@echo ""
	@echo "Exemplos:"
	@echo "  make version      # Mostra: $(FACTORY_VERSION)"
	@echo "  make tarball      # Gera: $(TARBALL)"
	@echo "  make release      # Gera tarball + tag"

version:
	@echo "$(FACTORY_VERSION)"

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found — skipping lint"; exit 0; } && shellcheck factory-init.sh

check: lint

tarball: lint
	@echo "Building $(TARBALL)..."
	@rm -rf "$(STAGE_DIR)"
	@mkdir -p "$(STAGE_DIR)/docs/agents" "$(STAGE_DIR)/docs/templates"
	@cp factory-init.sh FACTORY-GUIDE.md CLAUDE.md .gitignore "$(STAGE_DIR)/"
	@chmod +x "$(STAGE_DIR)/factory-init.sh"
	@cp docs/agents/*.md "$(STAGE_DIR)/docs/agents/"
	@cp -r docs/templates/. "$(STAGE_DIR)/docs/templates/"
	@cd /tmp && tar czf "$(CURDIR)/$(TARBALL)" "factory-$(FACTORY_VERSION)"
	@rm -rf "$(STAGE_DIR)"
	@echo "Created $(TARBALL)"

version-sync:
	@sed -i 's/^\*\*Version:\*\* _.*/\*\*Version:\*\* _$(FACTORY_VERSION)_/' FACTORY-GUIDE.md 2>/dev/null || \
	  sed -i '' 's/^\*\*Version:\*\* _.*/\*\*Version:\*\* _$(FACTORY_VERSION)_/' FACTORY-GUIDE.md
	@sed -i 's/^version: .*/version: $(FACTORY_VERSION)/' docs/templates/INDEX.md 2>/dev/null || \
	  sed -i '' 's/^version: .*/version: $(FACTORY_VERSION)/' docs/templates/INDEX.md
	@echo "Synced version $(FACTORY_VERSION) into FACTORY-GUIDE.md and docs/templates/INDEX.md"

clean:
	@rm -f factory-*.tar.gz
	@echo "Cleaned tarballs"

tag:
	@if git tag -l "v$(FACTORY_VERSION)" | grep -q .; then \
	  echo "Tag v$(FACTORY_VERSION) already exists"; exit 1; \
	fi
	@git tag -a "v$(FACTORY_VERSION)" -m "Release v$(FACTORY_VERSION)"
	@echo "Created tag v$(FACTORY_VERSION). Push with: git push origin v$(FACTORY_VERSION)"

release: version-sync tarball tag
	@echo ""
	@echo "✅ Release v$(FACTORY_VERSION) completo!"
	@echo ""
	@echo "Artefatos:"
	@echo "  - $(TARBALL)"
	@echo "  - Tag: v$(FACTORY_VERSION)"
	@echo ""
	@echo "Próximos passos:"
	@echo "  git push origin v$(FACTORY_VERSION)"
	@echo "  git push origin $(shell git branch --show-current)"
