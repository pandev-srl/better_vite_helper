# frozen_string_literal: true

require "rails_helper"
require "generator_spec"
require "generators/better_vite_helper/install/install_generator"

RSpec.describe BetterViteHelper::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __dir__)

  before do
    prepare_destination
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "generator execution" do
    before { run_generator }

    it "creates vite.config.js" do
      assert_file "vite.config.js" do |content|
        expect(content).to include("defineConfig")
        expect(content).to include("port: 5173")
        expect(content).to include('outDir: "public/assets"')
        expect(content).to include("manifest: true")
      end
    end

    it "creates postcss.config.js" do
      assert_file "postcss.config.js" do |content|
        expect(content).to include("@tailwindcss/postcss")
      end
    end
  end
end
