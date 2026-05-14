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

## Adding a New Locale

1. Copy `src/locales/en.env` to `src/locales/XX.env`
2. Translate all strings
3. Add `XX` to `LOCALES` in `Makefile`
4. Run `make build-all`

---

## License

MIT — See source files for details.
