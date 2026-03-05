require "test_helper"

module Marquee
  module Admin
    class PagesControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      test "GET /admin/pages lists pages" do
        Marquee::Page.create!(title: "Pricing", slug: "pricing", status: "published", published_at: Time.current, template_path: "marquee_pages/test_page")
        Marquee::Page.create!(title: "About", slug: "about", status: "draft", template_path: "marquee_pages/test_page")

        get "/admin/marquee/pages"
        assert_response :success
        assert_match "Pricing", response.body
        assert_match "About", response.body
        assert_match "published", response.body
        assert_match "draft", response.body
      end
    end
  end
end
