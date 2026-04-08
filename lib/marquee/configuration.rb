module Marquee
  class Configuration
    attr_accessor :site_name, :site_tagline,
                  :admin_auth, :current_user_method,
                  :admin_path, :public_path,
                  :enable_tracking, :event_adapter,
                  :on_lead_created,
                  :on_bot_detected

    def initialize
      @site_name = "My Site"
      @site_tagline = nil
      @admin_auth = nil
      @current_user_method = nil
      @admin_path = "/admin/site"
      @public_path = "/"
      @enable_tracking = true
      @event_adapter = Marquee::Events::LogAdapter.new
    end
  end
end
