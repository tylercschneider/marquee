module Marquee
  class Configuration
    attr_accessor :site_name, :site_tagline,
                  :admin_auth, :current_user_method,
                  :admin_path, :public_path,
                  :enable_tracking, :event_adapter,
                  :admin_base_controller

    def initialize
      @site_name = "My Site"
      @site_tagline = nil
      @admin_auth = nil
      @current_user_method = nil
      @admin_path = "/admin/site"
      @public_path = "/"
      @enable_tracking = true
      @event_adapter = Marquee::Events::LogAdapter.new
      @admin_base_controller = "ActionController::Base"
    end
  end
end
