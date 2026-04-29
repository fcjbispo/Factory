FACTORY_VERSION := $(shell sed -n 's/^FACTORY_VERSION="\([^"]*\)"/\1/p' factory-init.sh)
TARBALL          := factory-$(FACTORY_VERSION).tar.gz
STAGE_DIR        := /tmp/factory-$(FACTORY_VERSION)

.PHONY: help tarball version clean

help:
	@echo "Factory Framework v$(FACTORY_VERSION)"
	@echo ""
	@echo "Alvos disponíveis:"
	@echo "  help     — Mostra esta ajuda"
	@echo "  version  — Mostra versão atual"
	@echo "  tarball  — Gera tarball da versão atual"
	@echo "  clean    — Remove tarballs gerados"

version:
	@echo "$(FACTORY_VERSION)"

tarball:
	@echo "Building $(TARBALL)..."
	@rm -rf "$(STAGE_DIR)"
	@mkdir -p "$(STAGE_DIR)/docs/agents" "$(STAGE_DIR)/docs/templates"
	@cp factory-init.sh FACTORY-GUIDE.md .gitignore "$(STAGE_DIR)/"
	@chmod +x "$(STAGE_DIR)/factory-init.sh"
	@cp docs/agents/*.md "$(STAGE_DIR)/docs/agents/"
	@cp -r docs/templates/. "$(STAGE_DIR)/docs/templates/"
	@cd /tmp && tar czf "$(CURDIR)/$(TARBALL)" "factory-$(FACTORY_VERSION)"
	@rm -rf "$(STAGE_DIR)"
	@echo "Created $(TARBALL)"

clean:
	@rm -f factory-*.tar.gz
	@echo "Cleaned tarballs"
