require "test_helper"

module Marquee
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "GET /:slug renders the page template_path" do
      Marquee::Page.create!(
        title: "Test Page", slug: "test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )

      get "/marquee/test"
      assert_response :success
      assert_match "Test Page", response.body
      assert_match "Test page content", response.body
    end

    test "GET /:slug returns 404 for draft page" do
      Marquee::Page.create!(title: "Draft", slug: "draft-page", template_path: "marquee_pages/test_page")

      get "/marquee/draft-page"
      assert_response :not_found
    end

    test "GET /:slug includes SEO meta tags from layout" do
      Marquee::Page.create!(
        title: "About", slug: "about-seo", status: "published", published_at: Time.current,
        template_path: "marquee_pages/test_page",
        meta_title: "About Us - TestApp", meta_description: "Learn about us"
      )

      get "/marquee/about-seo"
      assert_response :success
      assert_match "About Us - TestApp", response.body
      assert_match "Learn about us", response.body
    end

    test "GET /:slug renders variant template when experiment is running" do
      page = Marquee::Page.create!(
        title: "Experiment Page", slug: "exp-page", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      experiment = Marquee::Experiment.create!(
        name: "Hero test", page: page, status: "running", started_at: Time.current
      )
      Marquee::Variant.create!(
        experiment: experiment, name: "Variant B",
        template_path: "marquee_pages/test_page_v2", weight: 1
      )

      # Pre-assign this visitor to Variant B
      get "/marquee/exp-page"
      visitor_token = cookies[:marquee_vid]

      # Replace assignment with Variant B
      assignment = Marquee::Assignment.find_by(visitor_token: visitor_token)
      variant_b = experiment.variants.find_by(name: "Variant B")
      assignment.update!(variant: variant_b)

      get "/marquee/exp-page"
      assert_response :success
      assert_match "Variant B content", response.body
    end

    test "GET /:slug renders default template when no experiment is running" do
      Marquee::Page.create!(
        title: "No Exp", slug: "no-exp", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )

      get "/marquee/no-exp"
      assert_response :success
      assert_match "Test page content", response.body
    end

    test "GET /:slug instruments page.viewed with variant info" do
      page = Marquee::Page.create!(
        title: "Tracked", slug: "tracked", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      experiment = Marquee::Experiment.create!(
        name: "Track test", page: page, status: "running", started_at: Time.current
      )
      Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )

      events = []
      original = Marquee.configuration.event_adapter
      Marquee.configuration.event_adapter = Class.new(Marquee::Events::BaseAdapter) do
        define_method(:track) { |name, props| events << [ name, props ] }
      end.new

      get "/marquee/tracked"
      assert_response :success

      event = events.find { |e| e[0] == "page.viewed" }
      assert event, "Expected page.viewed event"
      assert_equal page.id, event[1][:page_id]
      assert event[1].key?(:variant_id), "Expected variant_id in event properties"
      assert event[1].key?(:experiment_id), "Expected experiment_id in event properties"
    ensure
      Marquee.configuration.event_adapter = original
    end
  end
end
