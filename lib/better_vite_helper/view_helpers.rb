# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module BetterViteHelper
  module ViewHelpers
    def vite_development?
      Rails.env.development? && vite_dev_server_running?
    end

    def vite_dev_server_running?
      return @vite_dev_server_running if defined?(@vite_dev_server_running)

      @vite_dev_server_running = begin
        uri = URI("#{BetterViteHelper.configuration.dev_server_url}/")
        Net::HTTP.get_response(uri)
        true
      rescue StandardError
        false
      end
    end

    def vite_manifest
      return {} if vite_development?

      @vite_manifest ||= begin
        manifest_path = BetterViteHelper.configuration.manifest_path
        JSON.parse(File.read(manifest_path))
      rescue Errno::ENOENT
        Rails.logger.error "Vite manifest not found at #{manifest_path}"
        raise "Vite manifest not found. Run 'yarn build' to generate assets."
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid Vite manifest: #{e.message}"
        raise "Invalid Vite manifest format"
      end
    end

    def vite_asset_path(entry_name)
      if vite_development?
        dev_asset_path(entry_name)
      else
        production_asset_path(entry_name)
      end
    end

    def vite_javascript_include_tag(entry_name, **options)
      path = vite_asset_path(entry_name)
      default_options = { type: "module", defer: true, crossorigin: "anonymous" }
      javascript_include_tag(path, **default_options.merge(options))
    end

    def vite_stylesheet_link_tag(entry_name, **options)
      return "" if vite_development?

      manifest_key = resolve_manifest_key(entry_name)
      asset = vite_manifest[manifest_key] or raise "Vite entry '#{entry_name}' not found in manifest"

      if manifest_key.include?("stylesheets") || asset["file"].end_with?(".css")
        css_path = build_asset_url(asset["file"])
        stylesheet_link_tag(css_path, **{ media: "all" }.merge(options))
      else
        ""
      end
    end

    def vite_image_path(source)
      full_path = resolve_image_path(source)
      vite_asset_path(full_path)
    end

    def vite_image_tag(source, **options)
      image_tag(vite_image_path(source), **options)
    end

    def reset_vite_manifest_cache!
      @vite_manifest = nil
    end

    def reset_vite_dev_server_cache!
      remove_instance_variable(:@vite_dev_server_running) if defined?(@vite_dev_server_running)
    end

    private

    def dev_asset_path(entry_name)
      base_url = resolved_asset_host || BetterViteHelper.configuration.dev_server_url
      case entry_name
      when "application.js"
        "#{base_url}/app/javascript/application.js"
      when "application.css"
        "#{base_url}/app/assets/stylesheets/application.css"
      else
        "#{base_url}/#{entry_name}"
      end
    end

    def production_asset_path(entry_name)
      manifest_key = resolve_manifest_key(entry_name)
      asset = vite_manifest[manifest_key] or raise "Vite entry '#{entry_name}' not found in manifest"
      build_asset_url(asset["file"])
    end

    def resolve_manifest_key(entry_name)
      case entry_name
      when "application.js"
        "app/javascript/application.js"
      when "application.css"
        "app/assets/stylesheets/application.css"
      else
        entry_name
      end
    end

    def build_asset_url(file)
      if resolved_asset_host
        "#{resolved_asset_host}/assets/#{file}"
      else
        "/assets/#{file}"
      end
    end

    def resolved_asset_host
      BetterViteHelper.configuration.asset_host || Rails.application.config.asset_host
    end

    def resolve_image_path(source)
      return source if source.start_with?("app/", "/", "http://", "https://")

      "#{BetterViteHelper.configuration.images_path}/#{source}"
    end
  end
end
