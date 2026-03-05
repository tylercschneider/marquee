module Marquee
  module Admin
    class BaseController < Marquee::ApplicationController
      layout "marquee/admin"

      before_action :authenticate_admin!

      private

      def authenticate_admin!
        return unless Marquee.configuration.admin_auth

        Marquee.configuration.admin_auth.call(self)
      end
    end
  end
end
