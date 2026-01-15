# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails Engine (plugin) that provides Vite helper utilities for Rails applications. Requires Rails >= 8.1.2, Ruby 3.4.7.

## Commands

```bash
# Testing
bundle exec rspec              # Run all specs
bundle exec rspec spec/path    # Run specific spec file
bin/test                       # Wrapper script for rspec

# Linting
bin/rubocop                    # Run RuboCop
bin/rubocop -a                 # Auto-fix offenses

# Setup
bundle install                 # Install dependencies
```

## Architecture

```
lib/
├── better_vite_helper.rb           # Main module entry point
├── better_vite_helper/
│   ├── version.rb                  # Version constant
│   └── railtie.rb                  # Rails::Railtie integration
└── tasks/
    └── better_vite_helper_tasks.rake

spec/
├── spec_helper.rb                  # SimpleCov + RSpec config
├── rails_helper.rb                 # Rails test environment
└── dummy/                          # Minimal Rails app for testing
```

## Test Coverage

SimpleCov configured with:
- Minimum 90% overall coverage
- Minimum 80% per-file coverage

## Conventional Commits

Formato: `<type>(<optional scope>): <description>`

### Types

| Type | Uso |
|------|-----|
| `feat` | Nuove feature (API/UI) |
| `fix` | Bug fix |
| `refactor` | Ristrutturazione codice senza cambiare comportamento |
| `perf` | Miglioramenti performance (tipo speciale di refactor) |
| `style` | Formattazione, whitespace (non cambia comportamento) |
| `test` | Aggiunta/correzione test |
| `docs` | Solo documentazione |
| `build` | Build tools, dipendenze, versioni |
| `ops` | Infrastruttura, CI/CD, deployment, backup |
| `chore` | Task di manutenzione (init, .gitignore) |

### Scope

- Opzionale
- Sostantivo che descrive una sezione del codebase
- Esempi: `feat(api):`, `fix(parser):`, `feat(lang):`
- NON usare identificatori di issue come scope

### Regole

- Usare imperativo presente: "add" non "added"
- Non capitalizzare la prima lettera della description
- Non terminare con punto
- Breaking changes: aggiungere `!` dopo type/scope (es. `feat!:` o `feat(api)!:`)
