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
        post "/leads", params: {
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
      get "/lead-page"
      vid = cookies[:marquee_vid]

      post "/leads", params: {
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

      post "/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id }
      }

      event = events.find { |e| e[0] == "lead.created" }
      assert event, "Expected lead.created event"
      assert_equal "user@example.com", event[1][:email]
    ensure
      Marquee.configuration.event_adapter = original
    end

    test "POST /leads redirects back to page on success" do
      post "/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id }
      }

      assert_redirected_to "/lead-page"
    end

    test "POST /leads with invalid data re-renders page" do
      assert_no_difference "Marquee::Lead.count" do
        post "/leads", params: {
          lead: { email: "", source_page_id: @page.id }
        }
      end

      assert_response :unprocessable_entity
    end

    test "POST /leads stores custom data fields" do
      post "/leads", params: {
        lead: { email: "user@example.com", source_page_id: @page.id, data: { company: "Acme" } }
      }

      assert_equal({ "company" => "Acme" }, Marquee::Lead.last.data)
    end

    test "POST /leads records conversion when visitor has experiment assignment" do
      experiment = Marquee::Experiment.create!(
        name: "Conv test", page: @page, status: "running", started_at: Time.current
      )
      variant = Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )

      # Visit page to get assigned
      get "/lead-page"
      vid = cookies[:marquee_vid]

      # Ensure assignment exists
      assert Marquee::Assignment.find_by(visitor_token: vid), "Expected assignment to exist"

      post "/leads", params: {
        lead: { email: "convert@example.com", source_page_id: @page.id }
      }

      lead = Marquee::Lead.last
      assert_equal experiment.id, lead.converted_experiment_id
      assert lead.converted_variant_id.present?
    end

    test "POST /leads does not set conversion fields when no experiment" do
      post "/leads", params: {
        lead: { email: "noexp@example.com", source_page_id: @page.id }
      }

      lead = Marquee::Lead.last
      assert_nil lead.converted_experiment_id
      assert_nil lead.converted_variant_id
    end

    test "POST /leads flags lead as bot when honeypot is filled" do
      post "/leads", params: {
        lead: { email: "bot@example.com", source_page_id: @page.id },
        company_url: "http://spam.com"
      }

      lead = Marquee::Lead.last
      assert lead.bot, "Expected lead to be flagged as bot"
      assert_redirected_to "/lead-page"
    end

    test "POST /leads calls on_lead_created callback when configured" do
      callback_leads = []
      original = Marquee.configuration.on_lead_created
      Marquee.configuration.on_lead_created = ->(lead) { callback_leads << lead }

      post "/leads", params: {
        lead: { email: "callback@example.com", source_page_id: @page.id }
      }

      assert_equal 1, callback_leads.size
      assert_equal "callback@example.com", callback_leads.first.email
    ensure
      Marquee.configuration.on_lead_created = original
    end
  end
end
