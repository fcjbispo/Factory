# =============================================================================
# Factory Framework — Locale Build Makefile
# =============================================================================
# Called by parent Makefile to build a single localized artifact.
#
# Inputs:
#   LANG     = locale code (en, pt, ...)
#   VERSION  = Factory version
#   OUTDIR   = output directory (absolute path)
#
# Outputs:
#   $(OUTDIR)/factory-init.sh  — localized shell script
#   $(OUTDIR)/docs/            — localized documentation
#   $(OUTDIR)/guides/          — localized guides
#
# Requires: envsubst (gettext)
# =============================================================================

LANG    ?= en
VERSION ?= 1.3.0
OUTDIR  ?= ../dist/$(LANG)

LOCALE_FILE := locales/$(LANG).env
SCRIPT_SRC  := factory-init.sh
DOCS_SRC    := docs
GUIDES_SRC  := docs/guides

# All markdown files under docs/
DOC_FILES := $(shell find $(DOCS_SRC) -type f -name '*.md' 2>/dev/null)
OUT_DOC_FILES := $(patsubst $(DOCS_SRC)/%,$(OUTDIR)/docs/%,$(DOC_FILES))

.PHONY: all dirs script docs guides

all: dirs script docs guides

dirs:
	@mkdir -p $(OUTDIR)/docs $(OUTDIR)/guides

script: $(OUTDIR)/factory-init.sh

$(OUTDIR)/factory-init.sh: $(SCRIPT_SRC) $(LOCALE_FILE)
	@echo "  Rendering factory-init.sh [$(LANG)]..."
	@{ \
		echo '#!/usr/bin/env bash'; \
		echo '# ============================================================================='; \
		echo '# factory-init.sh'; \
		echo '# Factory project manager — localized build ($(LANG))'; \
		echo '# ============================================================================='; \
		echo ''; \
		echo 'set -euo pipefail'; \
		echo ''; \
		echo '# ─── Embedded Localization ($(LANG)) ───'; \
		cat $(LOCALE_FILE); \
		echo ''; \
		echo '# ─── Configuration ───'; \
		echo 'FACTORY_VERSION="$(VERSION)"'; \
		echo 'FACTORY_ROOT="$$(cd "$$(dirname "$${BASH_SOURCE[0]}")" \u0026\u0026 pwd)"'; \
		echo 'PROJECTS_DIR="$${FACTORY_PROJECTS_DIR:-$$HOME/Dev/Projects}"'; \
		echo 'TEMPLATES_DIR="$$FACTORY_ROOT/docs/templates"'; \
		echo 'AGENTS_DIR="$$FACTORY_ROOT/docs/agents"'; \
		echo 'GLOBAL_AGENTS_DIR="$$HOME/.claude/agents"'; \
		echo 'CONFIG_FILE=".factory"'; \
		echo ''; \
		tail -n +40 $(SCRIPT_SRC); \
	} > $@
	@chmod +x $@

docs: $(OUT_DOC_FILES)

$(OUTDIR)/docs/%.md: $(DOCS_SRC)/%.md $(LOCALE_FILE)
	@mkdir -p $(dir $@)
	@set -a; . $(LOCALE_FILE); set +a; \
		envsubst '$i18n_' < $< > $@

guides: $(OUTDIR)/guides/FACTORY-GUIDE.md

$(OUTDIR)/guides/FACTORY-GUIDE.md: $(GUIDES_SRC)/FACTORY-GUIDE.md $(LOCALE_FILE)
	@set -a; . $(LOCALE_FILE); set +a; \
		envsubst '$i18n_' < $< > $@
