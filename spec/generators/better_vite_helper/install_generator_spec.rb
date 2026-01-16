# frozen_string_literal: true

require "rails_helper"
require "generator_spec"
require "generators/better_vite_helper/install/install_generator"

RSpec.describe BetterViteHelper::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __dir__)

  before do
    prepare_destination
    # Create necessary directories for the generator
    FileUtils.mkdir_p(File.join(destination_root, "app/views/layouts"))
    FileUtils.mkdir_p(File.join(destination_root, "app/assets/stylesheets"))
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "generator execution" do
    before { run_generator %w[--skip-install --skip-layout] }

    it "creates package.json" do
      assert_file "package.json" do |content|
        expect(content).to include('"dev"')
        expect(content).to include("vite --host 0.0.0.0 --port 5173")
        expect(content).to include('"build"')
      end
    end

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

    it "creates app/javascript/application.js" do
      assert_file "app/javascript/application.js" do |content|
        expect(content).to include("import.meta.glob")
        expect(content).to include("application.css")
      end
    end

    it "creates app/assets/stylesheets/application.css" do
      assert_file "app/assets/stylesheets/application.css" do |content|
        expect(content).to include("@import \"tailwindcss\"")
      end
    end

    it "updates .gitignore" do
      assert_file ".gitignore" do |content|
        expect(content).to include("/node_modules")
        expect(content).to include("/.vite")
        expect(content).to include("/.yarn/*")
        expect(content).to include("*.log")
      end
    end
  end

  describe "with existing .gitignore" do
    before do
      File.write(File.join(destination_root, ".gitignore"), "# Existing content\n")
      run_generator %w[--skip-install --skip-layout]
    end

    it "appends to existing .gitignore" do
      assert_file ".gitignore" do |content|
        expect(content).to include("# Existing content")
        expect(content).to include("/node_modules")
      end
    end
  end

  describe "layout update" do
    before do
      layout_content = <<~ERB
        <!DOCTYPE html>
        <html>
          <head>
            <%= stylesheet_link_tag "application" %>
          </head>
          <body>
            <%= yield %>
          </body>
        </html>
      ERB
      File.write(File.join(destination_root, "app/views/layouts/application.html.erb"), layout_content)
      run_generator %w[--skip-install]
    end

    it "replaces stylesheet_link_tag with vite_stylesheet_link_tag" do
      assert_file "app/views/layouts/application.html.erb" do |content|
        expect(content).to include("vite_stylesheet_link_tag")
        expect(content).not_to match(/<%=\s*stylesheet_link_tag/)
      end
    end

    it "adds vite_javascript_include_tag" do
      assert_file "app/views/layouts/application.html.erb" do |content|
        expect(content).to include("vite_javascript_include_tag")
      end
    end
  end
end
