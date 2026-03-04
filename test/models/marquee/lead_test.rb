require "test_helper"

module Marquee
  class LeadTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test", slug: "lead-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
    end

    test "requires email" do
      lead = Marquee::Lead.new(source_page: @page)
      assert_not lead.valid?
      assert_includes lead.errors[:email], "can't be blank"
    end

    test "requires source_page" do
      lead = Marquee::Lead.new(email: "test@example.com")
      assert_not lead.valid?
      assert_includes lead.errors[:source_page], "must exist"
    end

    test "defaults status to new" do
      lead = Marquee::Lead.new(email: "test@example.com", source_page: @page)
      assert_equal "new", lead.status
    end

    test "defaults data to empty hash" do
      lead = Marquee::Lead.new(email: "test@example.com", source_page: @page)
      assert_equal({}, lead.data)
    end

    test "validates status inclusion" do
      lead = Marquee::Lead.new(email: "test@example.com", source_page: @page, status: "invalid")
      assert_not lead.valid?
      assert_includes lead.errors[:status], "is not included in the list"
    end

    test "validates email format" do
      lead = Marquee::Lead.new(email: "not-an-email", source_page: @page)
      assert_not lead.valid?
      assert_includes lead.errors[:email], "is invalid"
    end

    test "creates lead with valid attributes" do
      lead = Marquee::Lead.create!(
        email: "test@example.com", name: "Test User",
        source_page: @page, visitor_token: "abc-123",
        data: { company: "Acme" }
      )
      assert_equal "test@example.com", lead.email
      assert_equal "Test User", lead.name
      assert_equal({ "company" => "Acme" }, lead.data)
    end

    test "belongs to source_page" do
      lead = Marquee::Lead.create!(email: "test@example.com", source_page: @page)
      assert_equal @page, lead.source_page
    end
  end
end
