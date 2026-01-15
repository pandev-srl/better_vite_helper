# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterViteHelper::VERSION do
  it "has a version number" do
    expect(BetterViteHelper::VERSION).not_to be_nil
  end

  it "follows semantic versioning format" do
    expect(BetterViteHelper::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end
end
