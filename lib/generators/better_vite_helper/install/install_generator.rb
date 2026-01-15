# frozen_string_literal: true

require "rails/generators"

module BetterViteHelper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Copies Vite and PostCSS configuration files to your application"

      def copy_vite_config
        copy_file "vite.config.js", "vite.config.js"
      end

      def copy_postcss_config
        copy_file "postcss.config.js", "postcss.config.js"
      end

      def copy_application_js
        copy_file "application.js", "app/javascript/application.js"
      end

      def show_post_install_message
        say ""
        say "BetterViteHelper installed successfully!", :green
        say ""
        say "Next steps:"
        say "  1. Run 'yarn add -D vite' to install Vite"
        say "  2. Create your CSS entry point at app/assets/stylesheets/application.css"
        say "  3. Run 'yarn vite' for development or 'yarn vite build' for production"
        say ""
      end
    end
  end
end
