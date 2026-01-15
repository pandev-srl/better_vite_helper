# frozen_string_literal: true

module BetterViteHelper
  class Configuration
    attr_accessor :asset_host, :images_path
    attr_writer :manifest_path, :dev_server_url

    def initialize
      @manifest_path = nil
      @dev_server_url = nil
      @asset_host = nil
      @images_path = "app/assets/images"
    end

    def manifest_path
      @manifest_path || default_manifest_path
    end

    def dev_server_url
      @dev_server_url || ENV.fetch("VITE_DEV_SERVER_URL", "http://localhost:5173")
    end

    private

    def default_manifest_path
      Rails.root.join("public/assets/.vite/manifest.json")
    end
  end
end
