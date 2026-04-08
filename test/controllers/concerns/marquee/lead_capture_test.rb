require "test_helper"

module Marquee
  class LeadCaptureTest < ActionDispatch::IntegrationTest
    setup do
      @page = Marquee::Page.create!(
        title: "Home", slug: "home", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
    end

    test "capture_marquee_lead creates a lead and instruments event" do
      events = []
      original = Marquee.configuration.event_adapter
      Marquee.configuration.event_adapter = Class.new(Marquee::Events::BaseAdapter) {
        define_method(:track) { |name, props| events << [ name, props ] }
      }.new

      assert_difference "Marquee::Lead.count", 1 do
        post "/lead-capture-test", params: {
          lead: { email: "user@example.com", name: "Test", source_page_id: @page.id }
        }
      end
      assert_response :success

      lead = Marquee::Lead.last
      assert_equal "user@example.com", lead.email
      assert lead.visitor_token.present?

      event = events.find { |e| e[0] == "lead.created" }
      assert event, "Expected lead.created event"
    ensure
      Marquee.configuration.event_adapter = original
    end

    test "capture_marquee_lead fires on_lead_created callback" do
      callback_leads = []
      original = Marquee.configuration.on_lead_created
      Marquee.configuration.on_lead_created = ->(lead) { callback_leads << lead }

      post "/lead-capture-test", params: {
        lead: { email: "callback@example.com", source_page_id: @page.id }
      }

      assert_equal 1, callback_leads.size
      assert_equal "callback@example.com", callback_leads.first.email
    ensure
      Marquee.configuration.on_lead_created = original
    end

    test "capture_marquee_lead records experiment conversion" do
      experiment = Marquee::Experiment.create!(
        name: "Conv test", page: @page, status: "running", started_at: Time.current
      )
      Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )

      # Visit page to get assigned
      get "/home"
      vid = cookies[:marquee_vid]
      assert Marquee::Assignment.find_by(visitor_token: vid)

      post "/lead-capture-test", params: {
        lead: { email: "convert@example.com", source_page_id: @page.id }
      }

      lead = Marquee::Lead.last
      assert_equal experiment.id, lead.converted_experiment_id
      assert lead.converted_variant_id.present?
    end

    test "capture_marquee_lead flags lead as bot when honeypot field is filled" do
      post "/lead-capture-test", params: {
        lead: { email: "bot@example.com", source_page_id: @page.id },
        company_url: "http://spam.com"
      }

      lead = Marquee::Lead.last
      assert_equal true, lead.bot
    end

    test "capture_marquee_lead does not flag lead as bot when honeypot is blank" do
      post "/lead-capture-test", params: {
        lead: { email: "human@example.com", source_page_id: @page.id },
        company_url: ""
      }

      lead = Marquee::Lead.last
      assert_equal false, lead.bot
    end

    test "capture_marquee_lead skips on_lead_created callback for bot leads" do
      callback_leads = []
      original = Marquee.configuration.on_lead_created
      Marquee.configuration.on_lead_created = ->(lead) { callback_leads << lead }

      post "/lead-capture-test", params: {
        lead: { email: "bot@example.com", source_page_id: @page.id },
        company_url: "http://spam.com"
      }

      assert Marquee::Lead.last.bot, "Expected lead to be flagged as bot"
      assert_empty callback_leads, "Expected on_lead_created NOT to fire for bot"
    ensure
      Marquee.configuration.on_lead_created = original
    end

    test "capture_marquee_lead returns unpersisted lead on validation failure" do
      assert_no_difference "Marquee::Lead.count" do
        post "/lead-capture-test", params: {
          lead: { email: "", source_page_id: @page.id }
        }
      end
      assert_response :unprocessable_entity
    end
  end
end
