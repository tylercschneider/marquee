require "test_helper"

module Marquee
  module Admin
    class FunnelsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @page = Marquee::Page.create!(
          title: "Landing", slug: "funnel-landing", status: "published",
          published_at: Time.current, template_path: "marquee_pages/test_page"
        )
        @funnel = Marquee::Funnel.create!(
          name: "Signup Flow", slug: "signup-flow", status: "published"
        )
        Marquee::FunnelStep.create!(
          funnel: @funnel, page: @page, position: 1, label: "Landing"
        )
      end

      test "GET /admin/funnels/:id shows funnel with step results" do
        Marquee::FunnelProgress.create!(
          funnel_step: @funnel.funnel_steps.first,
          visitor_token: "v1"
        )

        get "/marquee/admin/funnels/#{@funnel.id}"
        assert_response :success
        assert_match "Signup Flow", response.body
        assert_match "Landing", response.body
        assert_match "funnel-landing", response.body
      end

      test "GET /admin/funnels lists funnels" do
        get "/marquee/admin/funnels"
        assert_response :success
        assert_match "Signup Flow", response.body
        assert_match "published", response.body
      end
    end
  end
end
