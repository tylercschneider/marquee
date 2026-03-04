module Marquee
  module Events
    class LogAdapter < BaseAdapter
      def track(event_name, properties = {})
        Rails.logger.info("[Marquee] #{event_name}: #{properties.inspect}")
      end
    end
  end
end
