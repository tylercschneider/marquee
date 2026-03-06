module Marquee
  class Engine < ::Rails::Engine
    isolate_namespace Marquee

    initializer "marquee.sync_pages", after: :finisher_hook do
      config.after_initialize do
        PageDefinition.sync!
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
        # DB not ready (migrations pending, table doesn't exist yet)
      end
    end
  end
end
