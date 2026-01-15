# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

# Require the gem being tested
require "better_vite_helper"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Disable features not needed for testing this gem
    config.eager_load = false
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false
    config.cache_classes = true

    # Required for Rails 8+
    config.secret_key_base = "test_secret_key_base_for_better_vite_helper"
  end
end
