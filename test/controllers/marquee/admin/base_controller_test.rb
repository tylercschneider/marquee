require "test_helper"

module Marquee
  module Admin
    class BaseControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      teardown do
        Marquee.configuration.admin_auth = nil
      end

      test "admin is accessible when admin_auth is nil" do
        Marquee.configuration.admin_auth = nil

        get "/marquee/admin/pages"
        assert_response :success
      end

      test "admin is blocked when admin_auth proc returns unauthorized" do
        Marquee.configuration.admin_auth = ->(controller) {
          controller.head :unauthorized
        }

        get "/marquee/admin/pages"
        assert_response :unauthorized
      end
    end
  end
end
