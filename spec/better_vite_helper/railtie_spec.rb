# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterViteHelper::Railtie do
  describe "view helper integration" do
    it "includes ViewHelpers in ActionView::Base" do
      expect(ActionView::Base.ancestors).to include(BetterViteHelper::ViewHelpers)
    end
  end
end
