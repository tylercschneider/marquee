require "test_helper"

module Marquee
  class LeadsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @page = Marquee::Page.create!(
        title: "Lead Page", slug: "lead-page", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
    end

    test "POST /leads creates a lead" do
      assert_difference "Marquee::Lead.count", 1 do
        post "/marquee/leads", params: {
          lead: { email: "user@example.com", name: "Test User", source_page_id: @page.id }
        }
      end

      lead = Marquee::Lead.last
      assert_equal "user@example.com", lead.email
      assert_equal "Test User", lead.name
      assert_equal @page.id, lead.source_page_id
      assert lead.visitor_token.present?
    end

    test "POST /leads sets visitor_token from cookie" do
      # Visit a page first to get a cookie
      get "/marquee/lead-page"
      vid = cookies[:marquee_vid]

      post "/marquee/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id }
      }

      assert_equal vid, Marquee::Lead.last.visitor_token
    end

    test "POST /leads fires lead.created event" do
      events = []
      original = Marquee.configuration.event_adapter
      Marquee.configuration.event_adapter = Class.new(Marquee::Events::BaseAdapter) do
        define_method(:track) { |name, props| events << [ name, props ] }
      end.new

      post "/marquee/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id }
      }

      event = events.find { |e| e[0] == "lead.created" }
      assert event, "Expected lead.created event"
      assert_equal "user@example.com", event[1][:email]
    ensure
      Marquee.configuration.event_adapter = original
    end

    test "POST /leads redirects back to page on success" do
      post "/marquee/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id }
      }

      assert_redirected_to "/marquee/lead-page"
    end

    test "POST /leads with invalid data re-renders page" do
      assert_no_difference "Marquee::Lead.count" do
        post "/marquee/leads", params: {
          lead: { email: "", source_page_id: @page.id }
        }
      end

      assert_response :unprocessable_entity
    end

    test "POST /leads stores custom data fields" do
      post "/marquee/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id, data: { company: "Acme" } }
      }

      assert_equal({ "company" => "Acme" }, Marquee::Lead.last.data)
    end
  end
end
