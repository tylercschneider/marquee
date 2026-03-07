module Marquee
  class Engine < ::Rails::Engine
    isolate_namespace Marquee

    initializer "marquee.sync_pages", after: :finisher_hook do
      config.after_initialize do
        PageDefinition.sync!
      rescue => e # rubocop:disable Style/RescueStandardError
        Rails.logger.warn "[Marquee] Auto-sync skipped: #{e.message}"
      end
    end
  end
end
