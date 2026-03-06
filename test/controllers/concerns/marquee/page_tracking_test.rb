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
  end
end
