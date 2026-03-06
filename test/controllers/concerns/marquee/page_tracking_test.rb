require "test_helper"

module Marquee
  class PageTrackingTest < ActionDispatch::IntegrationTest
    test "track_marquee_page sets @page and instruments page.viewed" do
      page = Marquee::Page.create!(
        title: "Home", slug: "home", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )

      events = []
      original = Marquee.configuration.event_adapter
      Marquee.configuration.event_adapter = Class.new(Marquee::Events::BaseAdapter) {
        define_method(:track) { |name, props| events << [ name, props ] }
      }.new

      get "/tracking-test?slug=home"
      assert_response :success

      event = events.find { |e| e[0] == "page.viewed" }
      assert event, "Expected page.viewed event"
      assert_equal page.id, event[1][:page_id]
      assert_equal "home", event[1][:slug]
    ensure
      Marquee.configuration.event_adapter = original
    end

    test "track_marquee_page records funnel progress" do
      page = Marquee::Page.create!(
        title: "Landing", slug: "landing", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      funnel = Marquee::Funnel.create!(name: "Signup", slug: "signup")
      Marquee::FunnelStep.create!(funnel: funnel, page: page, position: 1, label: "Landing")

      assert_difference "Marquee::FunnelProgress.count", 1 do
        get "/tracking-test?slug=landing"
      end
      assert_response :success
    end

    test "track_marquee_page instruments variant info when experiment is running" do
      page = Marquee::Page.create!(
        title: "Exp Page", slug: "exp", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      experiment = Marquee::Experiment.create!(
        name: "Hero test", page: page, status: "running", started_at: Time.current
      )
      Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )

      events = []
      original = Marquee.configuration.event_adapter
      Marquee.configuration.event_adapter = Class.new(Marquee::Events::BaseAdapter) {
        define_method(:track) { |name, props| events << [ name, props ] }
      }.new

      get "/tracking-test?slug=exp"
      assert_response :success

      event = events.find { |e| e[0] == "page.viewed" }
      assert event, "Expected page.viewed event"
      assert event[1].key?(:experiment_id), "Expected experiment_id"
      assert event[1].key?(:variant_id), "Expected variant_id"
    ensure
      Marquee.configuration.event_adapter = original
    end

    test "track_marquee_page skips tracking when page is not found" do
      get "/tracking-test?slug=nonexistent"
      assert_response :success
    end
  end
end
