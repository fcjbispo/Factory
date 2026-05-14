# Factory Framework

> Framework for managing and executing software projects with AI agents.
> Integrates **Domain-Driven Design (DDD)** and **Spec-Driven Development (SDD)** as its central paradigm.

This repository contains the **source** of the Factory Framework. Localized distribution packages are built from this source.

---

## Structure

```
Factory/
├── src/                    ← Source of truth (English base + locales)
│   ├── factory-init.sh     ← Script source with $i18n_ markers
│   ├── locales/
│   │   ├── en.env          ← English strings (base/fallback)
│   │   └── pt.env          ← Portuguese strings
│   ├── docs/               ← Document templates with $i18n_ markers
│   └── ...
├── dist/                   ← Compiled localized artifacts (committed)
│   ├── factory-1.3.0.en.tar.gz
│   └── factory-1.3.0.pt.tar.gz
└── Makefile                ← Build system
```

---

## Building

```bash
# Build all locales
make build-all

# Build specific locale
make build LANG=en

# Clean artifacts
make clean
```

---

## Installation

Download the appropriate localized package from `dist/`:

```bash
# English
tar xzf dist/factory-1.3.0.en.tar.gz

# Portuguese
tar xzf dist/factory-1.3.0.pt.tar.gz
```

Then run `./factory-init.sh help` for usage.

---

## Maintenance Workflow

When modifying base (English) documents in `src/`:

### After editing any template or guide

```bash
# 1. Rebuild all locales
make clean && make build-all

# 2. Verify the artifacts
ls -la dist/

# 3. Commit both source changes AND rebuilt artifacts
git add -A
git commit -m "docs(en): improve X section

- Updates src/docs/templates/X.md
- Rebuilds dist/ for all locales"
```

### Critical rules

1. **Never edit `dist/` directly.** It is auto-generated from `src/`.
2. **Always rebuild after source changes.** `make build-all` generates fresh `.tar.gz` files.
3. **Commit both `src/` and `dist/` together.** This keeps source and artifacts in sync.
4. **Never commit staging directories.** The `.gitignore` blocks `dist/en/` and `dist/pt/` — only `.tar.gz` files are tracked.
5. **When adding `$i18n_*` variables:** add the English default to `src/locales/en.env` AND the Portuguese translation to `src/locales/pt.env`. Missing variables break the build.

### When adding a new document

1. Create the document in `src/docs/` (English base)
2. Add `$i18n_*` markers where localization is needed
3. Add corresponding strings to `src/locales/en.env` and `src/locales/pt.env`
4. Run `make build-all`
5. Commit source + artifacts + locale files

### When removing a document

1. Delete from `src/docs/`
2. Remove unused `$i18n_*` strings from `src/locales/en.env` and `src/locales/pt.env`
3. Run `make build-all`
4. Commit source + artifacts + locale files

---

## Adding a New Locale

1. Copy `src/locales/en.env` to `src/locales/XX.env`
2. Translate all strings
3. Add `XX` to `LOCALES` in `Makefile`
4. Run `make build-all`

---

## License

MIT — See source files for details.
