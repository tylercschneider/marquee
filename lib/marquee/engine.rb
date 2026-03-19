module Marquee
  class Engine < ::Rails::Engine
    isolate_namespace Marquee

    initializer "marquee.url_helpers" do
      ActiveSupport.on_load(:action_controller) do
        helper Rails.application.routes.url_helpers
      end
    end

    config.after_initialize do
      PageDefinition.sync!
    rescue => e # rubocop:disable Style/RescueStandardError
      Rails.logger.warn "[Marquee] Auto-sync skipped: #{e.message}"
    end
  end
end
