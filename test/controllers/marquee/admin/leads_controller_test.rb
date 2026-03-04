require "test_helper"

module Marquee
  module Admin
    class LeadsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @page = Marquee::Page.create!(
          title: "Lead Page", slug: "admin-lead-test", status: "published",
          published_at: Time.current, template_path: "marquee_pages/test_page"
        )
      end

      test "GET /admin/leads lists leads" do
        Marquee::Lead.create!(email: "alice@example.com", name: "Alice", source_page: @page, visitor_token: "v1")
        Marquee::Lead.create!(email: "bob@example.com", source_page: @page, visitor_token: "v2")

        get "/marquee/admin/leads"
        assert_response :success
        assert_match "alice@example.com", response.body
        assert_match "bob@example.com", response.body
      end

      test "GET /admin/leads shows status and source page" do
        Marquee::Lead.create!(email: "alice@example.com", source_page: @page, visitor_token: "v1")

        get "/marquee/admin/leads"
        assert_response :success
        assert_match "new", response.body
        assert_match "Lead Page", response.body
      end
    end
  end
end
