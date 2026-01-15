# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterViteHelper::Configuration do
  subject(:configuration) { described_class.new }

  describe "#manifest_path" do
    it "defaults to Rails.root.join('public/assets/.vite/manifest.json')" do
      expected = Rails.root.join("public/assets/.vite/manifest.json")
      expect(configuration.manifest_path).to eq(expected)
    end

    it "can be customized" do
      custom_path = "/custom/manifest.json"
      configuration.manifest_path = custom_path
      expect(configuration.manifest_path).to eq(custom_path)
    end
  end

  describe "#dev_server_url" do
    it "defaults to http://localhost:5173" do
      expect(configuration.dev_server_url).to eq("http://localhost:5173")
    end

    context "when VITE_DEV_SERVER_URL is set" do
      around do |example|
        original = ENV["VITE_DEV_SERVER_URL"]
        ENV["VITE_DEV_SERVER_URL"] = "http://custom:3000"
        example.run
      ensure
        if original.nil?
          ENV.delete("VITE_DEV_SERVER_URL")
        else
          ENV["VITE_DEV_SERVER_URL"] = original
        end
      end

      it "uses the environment variable" do
        config = described_class.new
        expect(config.dev_server_url).to eq("http://custom:3000")
      end
    end

    it "can be customized" do
      configuration.dev_server_url = "http://vite:4000"
      expect(configuration.dev_server_url).to eq("http://vite:4000")
    end
  end

  describe "#asset_host" do
    it "defaults to nil" do
      expect(configuration.asset_host).to be_nil
    end

    it "can be customized" do
      configuration.asset_host = "https://cdn.example.com"
      expect(configuration.asset_host).to eq("https://cdn.example.com")
    end
  end
end
