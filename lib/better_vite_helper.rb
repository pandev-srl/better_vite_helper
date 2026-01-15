# frozen_string_literal: true

require "better_vite_helper/version"
require "better_vite_helper/configuration"
require "better_vite_helper/view_helpers"
require "better_vite_helper/railtie"

module BetterViteHelper
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
