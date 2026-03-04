module Marquee
  module Events
    class NullAdapter < BaseAdapter
      def track(event_name, properties = {})
        # no-op
      end
    end
  end
end
