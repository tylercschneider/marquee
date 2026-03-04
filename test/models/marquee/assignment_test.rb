require "test_helper"

module Marquee
  class AssignmentTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test", slug: "assign-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @experiment = Marquee::Experiment.create!(name: "Test", page: @page, status: "running", started_at: Time.current)
      @variant = Marquee::Variant.create!(experiment: @experiment, name: "Control", template_path: "marquee_pages/test_page", is_control: true)
    end

    test "requires experiment" do
      assignment = Marquee::Assignment.new(variant: @variant, visitor_token: "abc", assigned_at: Time.current)
      assert_not assignment.valid?
      assert_includes assignment.errors[:experiment], "must exist"
    end

    test "requires variant" do
      assignment = Marquee::Assignment.new(experiment: @experiment, visitor_token: "abc", assigned_at: Time.current)
      assert_not assignment.valid?
      assert_includes assignment.errors[:variant], "must exist"
    end

    test "requires visitor_token" do
      assignment = Marquee::Assignment.new(experiment: @experiment, variant: @variant, assigned_at: Time.current)
      assert_not assignment.valid?
      assert_includes assignment.errors[:visitor_token], "can't be blank"
    end

    test "requires assigned_at" do
      assignment = Marquee::Assignment.new(experiment: @experiment, variant: @variant, visitor_token: "abc")
      assert_not assignment.valid?
      assert_includes assignment.errors[:assigned_at], "can't be blank"
    end

    test "enforces unique visitor per experiment" do
      Marquee::Assignment.create!(experiment: @experiment, variant: @variant, visitor_token: "visitor-1", assigned_at: Time.current)

      duplicate = Marquee::Assignment.new(experiment: @experiment, variant: @variant, visitor_token: "visitor-1", assigned_at: Time.current)
      assert_not duplicate.valid?
      assert_includes duplicate.errors[:visitor_token], "has already been taken"
    end

    test "allows same visitor in different experiments" do
      experiment2 = Marquee::Experiment.create!(name: "Test 2", page: @page, status: "running", started_at: Time.current)
      variant2 = Marquee::Variant.create!(experiment: experiment2, name: "Control", template_path: "marquee_pages/test_page")

      Marquee::Assignment.create!(experiment: @experiment, variant: @variant, visitor_token: "visitor-1", assigned_at: Time.current)
      assignment2 = Marquee::Assignment.new(experiment: experiment2, variant: variant2, visitor_token: "visitor-1", assigned_at: Time.current)

      assert assignment2.valid?
    end
  end
end
