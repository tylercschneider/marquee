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
        get "/admin/marquee/experiments"
        assert_response :success
        assert_match "Hero Test", response.body
        assert_match "running", response.body
      end

      test "POST start changes draft to running" do
        draft = Marquee::Experiment.create!(name: "Draft", page: @page, status: "draft")
        post "/admin/marquee/experiments/#{draft.id}/start"
        assert_redirected_to "/admin/marquee/experiments/#{draft.id}"
        draft.reload
        assert_equal "running", draft.status
        assert_not_nil draft.started_at
      end

      test "POST pause changes running to paused" do
        post "/admin/marquee/experiments/#{@experiment.id}/pause"
        assert_redirected_to "/admin/marquee/experiments/#{@experiment.id}"
        @experiment.reload
        assert_equal "paused", @experiment.status
      end

      test "POST resume changes paused to running" do
        @experiment.update!(status: "paused")
        post "/admin/marquee/experiments/#{@experiment.id}/resume"
        assert_redirected_to "/admin/marquee/experiments/#{@experiment.id}"
        @experiment.reload
        assert_equal "running", @experiment.status
      end

      test "POST complete changes running to completed" do
        post "/admin/marquee/experiments/#{@experiment.id}/complete"
        assert_redirected_to "/admin/marquee/experiments/#{@experiment.id}"
        @experiment.reload
        assert_equal "completed", @experiment.status
        assert_not_nil @experiment.ended_at
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

        get "/admin/marquee/experiments/#{@experiment.id}"
        assert_response :success
        assert_match "Hero Test", response.body
        assert_match "Control", response.body
        assert_match "Variant B", response.body
      end
    end
  end
end
