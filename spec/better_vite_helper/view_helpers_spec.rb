# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterViteHelper::ViewHelpers do
  let(:view_context) do
    Class.new(ActionView::Base) do
      include BetterViteHelper::ViewHelpers
    end.new(ActionView::LookupContext.new([]), {}, nil)
  end

  before do
    BetterViteHelper.reset_configuration!
    view_context.reset_vite_dev_server_cache!
    view_context.reset_vite_manifest_cache!
  end

  describe "#vite_development?" do
    context "in development environment with server running" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns true" do
        expect(view_context.vite_development?).to be true
      end
    end

    context "in production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "returns false" do
        expect(view_context.vite_development?).to be false
      end
    end

    context "in development with server not running" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_raise(Errno::ECONNREFUSED)
      end

      it "returns false" do
        expect(view_context.vite_development?).to be false
      end
    end
  end

  describe "#vite_dev_server_running?" do
    context "when server responds" do
      before do
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns true" do
        expect(view_context.vite_dev_server_running?).to be true
      end

      it "caches the result" do
        view_context.vite_dev_server_running?
        view_context.vite_dev_server_running?
        expect(WebMock).to have_requested(:get, "http://localhost:5173/").once
      end
    end

    context "when server returns 404" do
      before do
        stub_request(:get, "http://localhost:5173/").to_return(status: 404)
      end

      it "still returns true (server is running)" do
        expect(view_context.vite_dev_server_running?).to be true
      end
    end

    context "when connection fails" do
      before do
        stub_request(:get, "http://localhost:5173/").to_raise(Errno::ECONNREFUSED)
      end

      it "returns false" do
        expect(view_context.vite_dev_server_running?).to be false
      end
    end

    context "with custom dev server URL" do
      before do
        BetterViteHelper.configure { |c| c.dev_server_url = "http://custom:4000" }
        stub_request(:get, "http://custom:4000/").to_return(status: 200)
      end

      it "uses the configured URL" do
        expect(view_context.vite_dev_server_running?).to be true
        expect(WebMock).to have_requested(:get, "http://custom:4000/")
      end
    end
  end

  describe "#vite_manifest" do
    let(:manifest_content) do
      {
        "app/javascript/application.js" => {
          "file" => "application-abc123.js",
          "isEntry" => true
        },
        "app/assets/stylesheets/application.css" => {
          "file" => "application-def456.css",
          "isEntry" => true
        }
      }
    end

    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    end

    context "when manifest exists" do
      before do
        allow(File).to receive(:read).and_return(manifest_content.to_json)
      end

      it "returns parsed manifest" do
        expect(view_context.vite_manifest).to eq(manifest_content)
      end

      it "caches the manifest" do
        view_context.vite_manifest
        view_context.vite_manifest
        expect(File).to have_received(:read).once
      end
    end

    context "when manifest does not exist" do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)
        allow(Rails.logger).to receive(:error)
      end

      it "raises an error" do
        expect { view_context.vite_manifest }.to raise_error(/Vite manifest not found/)
      end

      it "logs the error" do
        begin
          view_context.vite_manifest
        rescue StandardError
          nil
        end
        expect(Rails.logger).to have_received(:error).with(/Vite manifest not found/)
      end
    end

    context "when manifest is invalid JSON" do
      before do
        allow(File).to receive(:read).and_return("invalid json")
        allow(Rails.logger).to receive(:error)
      end

      it "raises an error" do
        expect { view_context.vite_manifest }.to raise_error(/Invalid Vite manifest format/)
      end
    end

    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns empty hash" do
        expect(view_context.vite_manifest).to eq({})
      end
    end
  end

  describe "#vite_asset_path" do
    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns dev server URL for application.js" do
        expect(view_context.vite_asset_path("application.js"))
          .to eq("http://localhost:5173/app/javascript/application.js")
      end

      it "returns dev server URL for application.css" do
        expect(view_context.vite_asset_path("application.css"))
          .to eq("http://localhost:5173/app/assets/stylesheets/application.css")
      end

      it "returns dev server URL for other entries" do
        expect(view_context.vite_asset_path("custom.js"))
          .to eq("http://localhost:5173/custom.js")
      end

      context "with custom asset_host" do
        before do
          BetterViteHelper.configure { |c| c.asset_host = "https://cdn.example.com" }
        end

        it "uses the asset_host" do
          expect(view_context.vite_asset_path("application.js"))
            .to eq("https://cdn.example.com/app/javascript/application.js")
        end
      end
    end

    context "in production mode" do
      let(:manifest_content) do
        {
          "app/javascript/application.js" => { "file" => "application-abc123.js" },
          "app/assets/stylesheets/application.css" => { "file" => "application-def456.css" }
        }
      end

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        allow(File).to receive(:read).and_return(manifest_content.to_json)
      end

      it "returns manifest path for application.js" do
        expect(view_context.vite_asset_path("application.js")).to eq("/assets/application-abc123.js")
      end

      it "returns manifest path for application.css" do
        expect(view_context.vite_asset_path("application.css")).to eq("/assets/application-def456.css")
      end

      it "raises error for missing entry" do
        expect { view_context.vite_asset_path("missing.js") }
          .to raise_error(/not found in manifest/)
      end

      context "with asset_host configured" do
        before do
          BetterViteHelper.configure { |c| c.asset_host = "https://cdn.example.com" }
        end

        it "includes the asset_host in the path" do
          expect(view_context.vite_asset_path("application.js"))
            .to eq("https://cdn.example.com/assets/application-abc123.js")
        end
      end
    end
  end

  describe "#vite_javascript_include_tag" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      stub_request(:get, "http://localhost:5173/").to_return(status: 200)
    end

    it "generates script tag with default options" do
      result = view_context.vite_javascript_include_tag("application.js")
      expect(result).to include('type="module"')
      expect(result).to include('defer="defer"')
      expect(result).to include('crossorigin="anonymous"')
    end

    it "allows overriding options" do
      result = view_context.vite_javascript_include_tag("application.js", defer: false)
      expect(result).not_to include("defer=")
    end

    it "allows adding custom options" do
      result = view_context.vite_javascript_include_tag("application.js", data: { turbo_track: "reload" })
      expect(result).to include('data-turbo-track="reload"')
    end
  end

  describe "#vite_stylesheet_link_tag" do
    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns empty string" do
        expect(view_context.vite_stylesheet_link_tag("application.css")).to eq("")
      end
    end

    context "in production mode" do
      let(:manifest_content) do
        {
          "app/assets/stylesheets/application.css" => { "file" => "application-def456.css" },
          "app/javascript/application.js" => { "file" => "application-abc123.js" }
        }
      end

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        allow(File).to receive(:read).and_return(manifest_content.to_json)
      end

      it "generates stylesheet link tag for CSS entry" do
        result = view_context.vite_stylesheet_link_tag("application.css")
        expect(result).to include('href="/assets/application-def456.css"')
        expect(result).to include('media="all"')
      end

      it "returns empty string for JS entry" do
        result = view_context.vite_stylesheet_link_tag("application.js")
        expect(result).to eq("")
      end

      it "allows custom options" do
        result = view_context.vite_stylesheet_link_tag("application.css", media: "print")
        expect(result).to include('media="print"')
      end
    end
  end

  describe "#vite_image_path" do
    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "returns dev server URL for short image name" do
        expect(view_context.vite_image_path("logo.png"))
          .to eq("http://localhost:5173/app/assets/images/logo.png")
      end

      it "returns dev server URL for full image path" do
        expect(view_context.vite_image_path("app/assets/images/icons/arrow.svg"))
          .to eq("http://localhost:5173/app/assets/images/icons/arrow.svg")
      end

      it "returns dev server URL for subdirectory image" do
        expect(view_context.vite_image_path("icons/arrow.svg"))
          .to eq("http://localhost:5173/app/assets/images/icons/arrow.svg")
      end

      it "handles various image formats" do
        %w[png jpg jpeg gif svg webp avif ico].each do |ext|
          expect(view_context.vite_image_path("test.#{ext}"))
            .to eq("http://localhost:5173/app/assets/images/test.#{ext}")
        end
      end

      it "passes through external URLs unchanged" do
        expect(view_context.vite_image_path("https://example.com/logo.png"))
          .to eq("http://localhost:5173/https://example.com/logo.png")
      end

      context "with custom images_path" do
        before do
          BetterViteHelper.configure { |c| c.images_path = "app/images" }
        end

        it "uses the custom images path" do
          expect(view_context.vite_image_path("logo.png"))
            .to eq("http://localhost:5173/app/images/logo.png")
        end
      end

      context "with custom asset_host" do
        before do
          BetterViteHelper.configure { |c| c.asset_host = "https://cdn.example.com" }
        end

        it "uses the asset_host" do
          expect(view_context.vite_image_path("logo.png"))
            .to eq("https://cdn.example.com/app/assets/images/logo.png")
        end
      end
    end

    context "in production mode" do
      let(:manifest_content) do
        {
          "app/javascript/application.js" => { "file" => "application-abc123.js" },
          "app/assets/images/logo.png" => { "file" => "logo-def456.png" },
          "app/assets/images/icons/arrow.svg" => { "file" => "arrow-ghi789.svg" }
        }
      end

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        allow(File).to receive(:read).and_return(manifest_content.to_json)
      end

      it "returns manifest path for short image name" do
        expect(view_context.vite_image_path("logo.png"))
          .to eq("/assets/logo-def456.png")
      end

      it "returns manifest path for full image path" do
        expect(view_context.vite_image_path("app/assets/images/icons/arrow.svg"))
          .to eq("/assets/arrow-ghi789.svg")
      end

      it "returns manifest path for subdirectory image" do
        expect(view_context.vite_image_path("icons/arrow.svg"))
          .to eq("/assets/arrow-ghi789.svg")
      end

      it "raises error for missing image" do
        expect { view_context.vite_image_path("missing.png") }
          .to raise_error(/not found in manifest/)
      end

      context "with asset_host configured" do
        before do
          BetterViteHelper.configure { |c| c.asset_host = "https://cdn.example.com" }
        end

        it "includes the asset_host in the path" do
          expect(view_context.vite_image_path("logo.png"))
            .to eq("https://cdn.example.com/assets/logo-def456.png")
        end
      end
    end
  end

  describe "#vite_image_tag" do
    context "in development mode" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        stub_request(:get, "http://localhost:5173/").to_return(status: 200)
      end

      it "generates img tag with correct src" do
        result = view_context.vite_image_tag("logo.png")
        expect(result).to include('src="http://localhost:5173/app/assets/images/logo.png"')
      end

      it "passes through alt option" do
        result = view_context.vite_image_tag("logo.png", alt: "Logo")
        expect(result).to include('alt="Logo"')
      end

      it "passes through class option" do
        result = view_context.vite_image_tag("logo.png", class: "logo-img")
        expect(result).to include('class="logo-img"')
      end

      it "passes through size option" do
        result = view_context.vite_image_tag("logo.png", size: "100x50")
        expect(result).to include('width="100"')
        expect(result).to include('height="50"')
      end

      it "supports data attributes" do
        result = view_context.vite_image_tag("logo.png", data: { controller: "image" })
        expect(result).to include('data-controller="image"')
      end

      it "supports multiple options together" do
        result = view_context.vite_image_tag(
          "logo.png",
          alt: "Company Logo",
          class: "header-logo",
          width: 200,
          data: { testid: "logo" }
        )
        expect(result).to include('alt="Company Logo"')
        expect(result).to include('class="header-logo"')
        expect(result).to include('width="200"')
        expect(result).to include('data-testid="logo"')
      end
    end

    context "in production mode" do
      let(:manifest_content) do
        {
          "app/assets/images/logo.png" => { "file" => "logo-def456.png" }
        }
      end

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        allow(File).to receive(:read).and_return(manifest_content.to_json)
      end

      it "generates img tag with hashed src" do
        result = view_context.vite_image_tag("logo.png")
        expect(result).to include('src="/assets/logo-def456.png"')
      end

      it "generates img tag with all options" do
        result = view_context.vite_image_tag("logo.png", alt: "Logo", class: "img-fluid")
        expect(result).to include('src="/assets/logo-def456.png"')
        expect(result).to include('alt="Logo"')
        expect(result).to include('class="img-fluid"')
      end
    end
  end

  describe "#reset_vite_manifest_cache!" do
    let(:manifest_content) { { "test" => { "file" => "test.js" } } }

    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      allow(File).to receive(:read).and_return(manifest_content.to_json)
    end

    it "clears the manifest cache" do
      view_context.vite_manifest
      view_context.reset_vite_manifest_cache!
      view_context.vite_manifest

      expect(File).to have_received(:read).twice
    end
  end

  describe "#reset_vite_dev_server_cache!" do
    before do
      stub_request(:get, "http://localhost:5173/").to_return(status: 200)
    end

    it "clears the dev server cache" do
      view_context.vite_dev_server_running?
      view_context.reset_vite_dev_server_cache!
      view_context.vite_dev_server_running?

      expect(WebMock).to have_requested(:get, "http://localhost:5173/").twice
    end
  end
end
