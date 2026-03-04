module Marquee
  module Events
    class AhoyAdapter < BaseAdapter
      class AhoyNotInstalled < StandardError; end

      def track(event_name, properties = {})
        unless defined?(::Ahoy)
          raise AhoyNotInstalled,
            "AhoyAdapter requires the ahoy_matey gem. Add `gem 'ahoy_matey'` to your Gemfile."
        end

        build_tracker.track(event_name, properties)
      end

      private

      def build_tracker
        ::Ahoy::Tracker.new
      end
    end
  end
end
