# BetterViteHelper

Rails Engine providing Vite view helpers with automatic dev server detection and manifest-based asset resolution.

## Requirements

- Ruby >= 3.4.7
- Rails >= 8.0.0, < 8.2

## Installation

Add to your Gemfile:

```ruby
gem "better_vite_helper"
```

Then run:

```bash
bundle install
bin/rails generate better_vite_helper:install
```

This copies `vite.config.js` and `postcss.config.js` to your application.

## Usage

### View Helpers

```erb
<%# Include JavaScript entry %>
<%= vite_javascript_include_tag "application.js" %>

<%# Include stylesheet (production only, Vite handles HMR in dev) %>
<%= vite_stylesheet_link_tag "application.css" %>

<%# Get asset path directly %>
<%= vite_asset_path "application.js" %>

<%# Check if dev server is running %>
<% if vite_development? %>
  <!-- dev mode -->
<% end %>
```

### Image Helpers

```erb
<%# Generate img tag with Vite-resolved src %>
<%= vite_image_tag "logo.png", alt: "Logo", class: "logo" %>

<%# Subdirectory images %>
<%= vite_image_tag "icons/arrow.svg", alt: "Arrow" %>

<%# Get image path directly %>
<%= vite_image_path "logo.png" %>
<%# Dev:  http://localhost:5173/app/assets/images/logo.png %>
<%# Prod: /assets/logo-abc123.png (with CDN if configured) %>
```

Images in `app/assets/images/` are automatically included in the Vite build via `import.meta.glob`.

### Configuration

```ruby
# config/initializers/better_vite_helper.rb
BetterViteHelper.configure do |config|
  config.dev_server_url = "http://localhost:5173"  # default, or ENV["VITE_DEV_SERVER_URL"]
  config.manifest_path = Rails.root.join("public/assets/.vite/manifest.json")  # default
  config.asset_host = "https://cdn.example.com"  # optional, falls back to Rails.application.config.asset_host
  config.images_path = "app/assets/images"  # default
end
```

## Development

```bash
bundle install
bundle exec rspec           # Run tests
bin/rubocop -a              # Lint and auto-fix
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
