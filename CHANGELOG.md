# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-01-16

### Added

- `vite_image_tag(source, **options)` helper for generating `<img>` tags with Vite-resolved src
- `vite_image_path(source)` helper for getting resolved image URLs
- `images_path` configuration option (default: `app/assets/images`)
- Auto-import of all images in `app/assets/images/**/*` via `import.meta.glob` in application.js template
- Support for short image names (`logo.png`), subdirectories (`icons/arrow.svg`), and full paths
- CDN support via `asset_host` configuration for image helpers
- Generator `--skip-install` option to skip npm dependency installation
- Generator `--skip-layout` option to skip layout file modification
- Generator now installs Tailwind CSS v4 and PostCSS dependencies (`@tailwindcss/postcss`, `postcss`, `tailwindcss`, `autoprefixer`)
- Generator creates `app/assets/stylesheets/application.css` with Tailwind CSS import
- Generator updates `.gitignore` with Node/Yarn/Vite entries (node_modules, .yarn, .vite, logs, cache)

### Changed

- Install generator is now fully automated:
  - Creates `package.json` if missing (with `type: "module"` and `dev`/`build` scripts)
  - Installs Vite and Tailwind CSS automatically via yarn or npm
  - Updates application layout with `vite_stylesheet_link_tag` and `vite_javascript_include_tag`
- Package.json script changed from `vite` to `dev` with `--host 0.0.0.0 --port 5173` options

### Fixed

- Generator now correctly checks file existence using `destination_root` for proper test support

## [0.1.0] - 2025-01-15

### Added

- Initial release
- View helpers: `vite_javascript_include_tag`, `vite_stylesheet_link_tag`, `vite_asset_path`
- Dev server detection: `vite_development?`, `vite_dev_server_running?`
- Manifest parsing for production assets
- Configuration via `BetterViteHelper.configure` block
- Install generator with Vite and PostCSS config templates
- Support for custom asset host / CDN
