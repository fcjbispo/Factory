FACTORY_VERSION := $(shell sed -n 's/^FACTORY_VERSION="\([^"]*\)"/\1/p' factory-init.sh)
TARBALL          := factory-$(FACTORY_VERSION).tar.gz
STAGE_DIR        := /tmp/factory-$(FACTORY_VERSION)
GITHUB_REPO      := fcjbispo/MyFactory

.PHONY: tarball version version-sync lint check clean tag

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
	@sed -i 's/^\*\*Version:\*\* _.*_/\*\*Version:\*\* _$(FACTORY_VERSION)_/' FACTORY-GUIDE.md 2>/dev/null || \
	  sed -i '' 's/^\*\*Version:\*\* _.*_/\*\*Version:\*\* _$(FACTORY_VERSION)_/' FACTORY-GUIDE.md
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