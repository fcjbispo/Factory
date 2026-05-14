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
#
# IMPORTANT: VERSION is auto-detected from the current git branch name.
#            Branches named 'vX.Y.Z' or 'vX.Y.Z_suffix' produce version X.Y.Z.
#            If not on a version branch, falls back to the hardcoded VERSION.
# =============================================================================

# Auto-detect version from current git branch (v1.3.0_localized → 1.3.0)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_VERSION := $(shell echo "$(GIT_BRANCH)" | sed -n 's/^v\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')

# Fallback to hardcoded version if not on a version branch
ifeq ($(GIT_VERSION),)
  VERSION := 1.3.0
else
  VERSION := $(GIT_VERSION)
endif

LOCALES := en pt
DIST_DIR := dist

.PHONY: all build-all build clean release check version-info

all: build-all

version-info:
	@echo "Current branch: $(GIT_BRANCH)"
	@echo "Detected version: $(VERSION)"

build-all: version-info $(patsubst %,$(DIST_DIR)/factory-$(VERSION).%.tar.gz,$(LOCALES))

# Default target: show help when 'make' is run without arguments
.DEFAULT_GOAL := help

help:
	@echo ""
	@echo "  Factory Framework — Build System"
	@echo "  Version: $(VERSION) | Branch: $(GIT_BRANCH)"
	@echo ""
	@echo "  make help               Show this help message"
	@echo "  make version-info       Show current branch and detected version"
	@echo "  make build-all          Build all locale packages (en, pt)"
	@echo "  make build LANG=en      Build specific locale package"
	@echo "  make clean              Remove dist/ artifacts"
	@echo "  make release            Build + show release steps"
	@echo "  make check              Verify build dependencies"
	@echo ""
	@echo "  Examples:"
	@echo "    make build-all                    # Build both EN and PT"
	@echo "    make build LANG=pt                # Build only PT-BR"
	@echo "    make clean && make build-all       # Clean rebuild"
	@echo ""
	@echo "  Maintenance:"
	@echo "    After editing src/ docs, run: make clean && make build-all"
	@echo "    Commit BOTH src/ and dist/ together to keep them in sync."
	@echo ""

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
