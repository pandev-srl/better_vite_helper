# frozen_string_literal: true

require "spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

RSpec.configure do |config|
  # Use transactional fixtures if you have ActiveRecord
  # config.use_transactional_fixtures = true

  # Infer spec type from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails backtrace frames
  config.filter_rails_from_backtrace!
end
