require "test_helper"

module Marquee
  class FunnelProgressTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Progress Page", slug: "funnel-progress-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @funnel = Marquee::Funnel.create!(name: "Test Flow", slug: "progress-test-flow")
      @step = Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 1, label: "Landing")
    end

    test "requires a funnel_step" do
      progress = Marquee::FunnelProgress.new(visitor_token: "abc123")
      progress.funnel_step = nil
      assert_not progress.valid?
      assert_includes progress.errors[:funnel_step], "must exist"
    end

    test "requires a visitor_token" do
      progress = Marquee::FunnelProgress.new(funnel_step: @step)
      assert_not progress.valid?
      assert_includes progress.errors[:visitor_token], "can't be blank"
    end

    test "enforces unique visitor per step" do
      Marquee::FunnelProgress.create!(funnel_step: @step, visitor_token: "visitor-1")
      duplicate = Marquee::FunnelProgress.new(funnel_step: @step, visitor_token: "visitor-1")
      assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save(validate: false) }
    end

    test "allows same visitor in different steps" do
      step2 = Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 2, label: "Pricing")
      Marquee::FunnelProgress.create!(funnel_step: @step, visitor_token: "visitor-1")
      progress = Marquee::FunnelProgress.new(funnel_step: step2, visitor_token: "visitor-1")
      assert progress.valid?
    end

    test "belongs to funnel_step" do
      progress = Marquee::FunnelProgress.create!(funnel_step: @step, visitor_token: "visitor-1")
      assert_equal @step, progress.funnel_step
    end
  end
end
