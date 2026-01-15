# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-15

### Added

- Initial release
- View helpers: `vite_javascript_include_tag`, `vite_stylesheet_link_tag`, `vite_asset_path`
- Dev server detection: `vite_development?`, `vite_dev_server_running?`
- Manifest parsing for production assets
- Configuration via `BetterViteHelper.configure` block
- Install generator with Vite and PostCSS config templates
- Support for custom asset host / CDN
