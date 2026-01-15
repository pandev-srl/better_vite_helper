# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterViteHelper do
  after { described_class.reset_configuration! }

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(BetterViteHelper::Configuration)
    end

    it "memoizes the configuration" do
      config1 = described_class.configuration
      config2 = described_class.configuration
      expect(config1).to be(config2)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure do |config|
        config.manifest_path = "/custom/path.json"
        config.dev_server_url = "http://custom:4000"
      end

      expect(described_class.configuration.manifest_path).to eq("/custom/path.json")
      expect(described_class.configuration.dev_server_url).to eq("http://custom:4000")
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration to defaults" do
      described_class.configure do |config|
        config.manifest_path = "/custom/path.json"
      end

      described_class.reset_configuration!

      expect(described_class.configuration.manifest_path)
        .to eq(Rails.root.join("public/assets/.vite/manifest.json"))
    end
  end
end
