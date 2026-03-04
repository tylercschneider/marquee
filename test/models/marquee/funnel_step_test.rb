require "test_helper"

module Marquee
  class FunnelStepTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Step Page", slug: "funnel-step-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @funnel = Marquee::Funnel.create!(name: "Test Flow", slug: "step-test-flow")
    end

    test "requires a funnel" do
      step = Marquee::FunnelStep.new(page: @page, position: 1, label: "Landing")
      step.funnel = nil
      assert_not step.valid?
      assert_includes step.errors[:funnel], "must exist"
    end

    test "requires a page" do
      step = Marquee::FunnelStep.new(funnel: @funnel, position: 1, label: "Landing")
      step.page = nil
      assert_not step.valid?
      assert_includes step.errors[:page], "must exist"
    end

    test "requires a position" do
      step = Marquee::FunnelStep.new(funnel: @funnel, page: @page, label: "Landing")
      assert_not step.valid?
      assert_includes step.errors[:position], "can't be blank"
    end

    test "requires a label" do
      step = Marquee::FunnelStep.new(funnel: @funnel, page: @page, position: 1)
      assert_not step.valid?
      assert_includes step.errors[:label], "can't be blank"
    end

    test "requires unique position within funnel" do
      Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 1, label: "Landing")
      page2 = Marquee::Page.create!(
        title: "Page 2", slug: "funnel-step-test-2", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      step = Marquee::FunnelStep.new(funnel: @funnel, page: page2, position: 1, label: "Pricing")
      assert_not step.valid?
      assert_includes step.errors[:position], "has already been taken"
    end

    test "allows same position in different funnels" do
      Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 1, label: "Landing")
      other_funnel = Marquee::Funnel.create!(name: "Other", slug: "other-flow")
      step = Marquee::FunnelStep.new(funnel: other_funnel, page: @page, position: 1, label: "Landing")
      assert step.valid?
    end

    test "belongs to funnel" do
      step = Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 1, label: "Landing")
      assert_equal @funnel, step.funnel
    end

    test "belongs to page" do
      step = Marquee::FunnelStep.create!(funnel: @funnel, page: @page, position: 1, label: "Landing")
      assert_equal @page, step.page
    end
  end
end
