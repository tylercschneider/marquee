require "test_helper"

module Marquee
  module Admin
    class ExperimentsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @page = Marquee::Page.create!(
          title: "Test", slug: "admin-exp-test", status: "published",
          published_at: Time.current, template_path: "marquee_pages/test_page"
        )
        @experiment = Marquee::Experiment.create!(
          name: "Hero Test", page: @page, status: "running", started_at: Time.current
        )
        @control = Marquee::Variant.create!(
          experiment: @experiment, name: "Control",
          template_path: "marquee_pages/test_page", is_control: true
        )
        @variant_b = Marquee::Variant.create!(
          experiment: @experiment, name: "Variant B",
          template_path: "marquee_pages/test_page_v2"
        )
      end

      test "GET /admin/experiments lists experiments" do
        get "/marquee/admin/experiments"
        assert_response :success
        assert_match "Hero Test", response.body
        assert_match "running", response.body
      end

      test "GET /admin/experiments/:id shows experiment with results" do
        Marquee::Assignment.create!(
          experiment: @experiment, variant: @control,
          visitor_token: "v1", assigned_at: Time.current
        )
        Marquee::Lead.create!(
          email: "test@example.com", source_page: @page,
          visitor_token: "v1",
          converted_experiment_id: @experiment.id,
          converted_variant_id: @control.id
        )

        get "/marquee/admin/experiments/#{@experiment.id}"
        assert_response :success
        assert_match "Hero Test", response.body
        assert_match "Control", response.body
        assert_match "Variant B", response.body
      end
    end
  end
end
