# frozen_string_literal: true

require "rails/generators"
require "json"

module BetterViteHelper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Installs Vite and configures your Rails application for BetterViteHelper"

      class_option :skip_install, type: :boolean, default: false,
                   desc: "Skip installing npm dependencies"
      class_option :skip_layout, type: :boolean, default: false,
                   desc: "Skip updating application layout"

      def create_package_json_if_missing
        return if File.exist?(File.join(destination_root, "package.json"))

        content = {
          "name" => File.basename(destination_root),
          "private" => true,
          "type" => "module",
          "scripts" => {
            "dev" => "vite --host 0.0.0.0 --port 5173",
            "build" => "vite build"
          }
        }
        create_file "package.json", JSON.pretty_generate(content) + "\n"
      end

      def update_gitignore
        gitignore_path = ".gitignore"

        entries = <<~GITIGNORE

          # Node/Yarn
          /node_modules

          # Logs
          *.log
          npm-debug.log*
          yarn-debug.log*
          yarn-error.log*

          # Vite
          /.vite

          # Cache
          .cache
          .eslintcache
          .stylelintcache

          # TypeScript
          *.tsbuildinfo

          # Yarn PnP
          /.pnp.*
          /.yarn/*
          !/.yarn/patches
          !/.yarn/plugins
          !/.yarn/releases
          !/.yarn/sdks
          !/.yarn/versions
        GITIGNORE

        if File.exist?(File.join(destination_root, gitignore_path))
          append_to_file gitignore_path, entries
        else
          create_file gitignore_path, entries.strip + "\n"
        end
      end

      def install_vite_dependencies
        return if options[:skip_install]

        say "Installing Vite and PostCSS dependencies...", :green

        deps = %w[vite @tailwindcss/postcss postcss tailwindcss autoprefixer]

        if File.exist?(File.join(destination_root, "yarn.lock")) || !File.exist?(File.join(destination_root, "package-lock.json"))
          run "yarn add -D #{deps.join(' ')}"
        else
          run "npm install --save-dev #{deps.join(' ')}"
        end
      end

      def copy_vite_config
        copy_file "vite.config.js", "vite.config.js"
      end

      def copy_postcss_config
        copy_file "postcss.config.js", "postcss.config.js"
      end

      def copy_application_js
        copy_file "application.js", "app/javascript/application.js"
      end

      def copy_application_css
        copy_file "application.css", "app/assets/stylesheets/application.css"
      end

      def update_application_layout
        return if options[:skip_layout]

        layout_path = "app/views/layouts/application.html.erb"
        return unless File.exist?(File.join(destination_root, layout_path))

        gsub_file layout_path,
          /<%=\s*stylesheet_link_tag\s+["']application["'].*%>/,
          '<%= vite_stylesheet_link_tag "application.css" %>'

        inject_into_file layout_path, before: "</body>" do
          "    <%= vite_javascript_include_tag \"application.js\" %>\n  "
        end
      end

      def show_post_install_message
        say ""
        say "BetterViteHelper installed successfully!", :green
        say ""
        say "To start development:"
        say "  yarn dev         # Start Vite dev server"
        say "  bin/rails server # Start Rails (in another terminal)"
        say ""
      end
    end
  end
end
