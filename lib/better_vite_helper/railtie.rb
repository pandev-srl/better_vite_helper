# frozen_string_literal: true

module BetterViteHelper
  class Railtie < ::Rails::Railtie
    initializer "better_vite_helper.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include BetterViteHelper::ViewHelpers
      end
    end
  end
end
