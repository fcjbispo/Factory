# =============================================================================
# Factory Framework — Master Makefile
# =============================================================================
# Build localized distribution packages from src/ (source of truth).
#
# Usage:
#   make build-all        Build all locale packages (en, pt)
#   make build LANG=en    Build specific locale
#   make clean            Remove dist/ artifacts
#   make release          Build + tag + push (requires git setup)
# =============================================================================

VERSION := 1.3.0
LOCALES := en pt
DIST_DIR := dist

.PHONY: all build-all build clean release check

all: build-all

build-all: $(patsubst %,$(DIST_DIR)/factory-$(VERSION).%.tar.gz,$(LOCALES))

$(DIST_DIR)/factory-$(VERSION).%.tar.gz: src/Makefile src/locales/%.env
	@echo "Building Factory $(VERSION) for locale: $*"
	@mkdir -p $(DIST_DIR)/$*
	@$(MAKE) -C src LANG=$* VERSION=$(VERSION) OUTDIR=$(PWD)/$(DIST_DIR)/$*
	@echo "Packaging factory-$(VERSION).$*.tar.gz..."
	@cd $(DIST_DIR)/$* && tar czf ../factory-$(VERSION).$*.tar.gz .
	@echo "Done: $(DIST_DIR)/factory-$(VERSION).$*.tar.gz"

clean:
	@echo "Removing dist/ artifacts..."
	@rm -rf $(DIST_DIR)

release: build-all
	@echo "Release $(VERSION) built. Manual steps:"
	@echo "  1. git tag v$(VERSION)"
	@echo "  2. git push origin v$(VERSION)"
	@echo "  3. Upload $(DIST_DIR)/factory-$(VERSION).*.tar.gz to GitHub releases"

check:
	@command -v envsubst >/dev/null 2>&1 || { echo "ERROR: envsubst (gettext) is required"; exit 1; }
	@echo "Build dependencies OK"
