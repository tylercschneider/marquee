module Marquee
  module Admin
    class BaseController < Marquee.configuration.admin_base_controller.constantize
      layout -> { custom_base_controller? ? nil : "marquee/admin" }

      before_action :authenticate_admin!, unless: :custom_base_controller?

      private

      def authenticate_admin!
        return unless Marquee.configuration.admin_auth

        Marquee.configuration.admin_auth.call(self)
      end

      def custom_base_controller?
        Marquee.configuration.admin_base_controller != "ActionController::Base"
      end
    end
  end
end
