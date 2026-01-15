require_relative "lib/better_vite_helper/version"

Gem::Specification.new do |spec|
  spec.name        = "better_vite_helper"
  spec.version     = BetterViteHelper::VERSION
  spec.authors     = [ "Umberto Peserico", "Alessio Bussolari" ]
  spec.email       = [ "umberto.peserico@pandev.it", "alessio.bussolari@pandev.it" ]
  spec.homepage    = "https://github.com/pandev-srl/better_vite_helper"
  spec.summary     = "Rails Engine providing Vite view helpers with automatic dev server detection"
  spec.description = "Rails Engine providing Vite view helpers with automatic dev server detection and manifest-based asset resolution for seamless Vite integration in Rails applications."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pandev-srl/better_vite_helper"
  spec.metadata["changelog_uri"] = "https://github.com/pandev-srl/better_vite_helper/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0", "< 8.2"
end
