module Marquee
  module Events
    class BaseAdapter
      def track(event_name, properties = {})
        raise NotImplementedError, "#{self.class}#track must be implemented"
      end
    end
  end
end
