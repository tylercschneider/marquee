require "test_helper"

module Marquee
  class FunnelTest < ActiveSupport::TestCase
    test "requires a name" do
      funnel = Marquee::Funnel.new(slug: "test-funnel")
      assert_not funnel.valid?
      assert_includes funnel.errors[:name], "can't be blank"
    end

    test "requires a slug" do
      funnel = Marquee::Funnel.new(name: "Test Funnel")
      assert_not funnel.valid?
      assert_includes funnel.errors[:slug], "can't be blank"
    end

    test "requires unique slug" do
      Marquee::Funnel.create!(name: "First", slug: "unique-slug")
      funnel = Marquee::Funnel.new(name: "Second", slug: "unique-slug")
      assert_not funnel.valid?
      assert_includes funnel.errors[:slug], "has already been taken"
    end

    test "defaults status to draft" do
      funnel = Marquee::Funnel.new(name: "Test", slug: "test")
      assert_equal "draft", funnel.status
    end

    test "validates status inclusion" do
      funnel = Marquee::Funnel.new(name: "Test", slug: "test", status: "invalid")
      assert_not funnel.valid?
      assert_includes funnel.errors[:status], "is not included in the list"
    end

    test "has many funnel_steps" do
      page = Marquee::Page.create!(
        title: "Step Page", slug: "funnel-step-page", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      funnel = Marquee::Funnel.create!(name: "Flow", slug: "flow")
      step = Marquee::FunnelStep.create!(funnel: funnel, page: page, position: 1, label: "Landing")
      assert_includes funnel.funnel_steps, step
    end

    test "has many pages through funnel_steps" do
      page = Marquee::Page.create!(
        title: "Step Page", slug: "funnel-through-page", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      funnel = Marquee::Funnel.create!(name: "Flow", slug: "through-flow")
      Marquee::FunnelStep.create!(funnel: funnel, page: page, position: 1, label: "Landing")
      assert_includes funnel.pages, page
    end

    test "destroys funnel_steps when destroyed" do
      page = Marquee::Page.create!(
        title: "Step Page", slug: "funnel-destroy-page", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      funnel = Marquee::Funnel.create!(name: "Flow", slug: "destroy-flow")
      Marquee::FunnelStep.create!(funnel: funnel, page: page, position: 1, label: "Landing")
      assert_difference "Marquee::FunnelStep.count", -1 do
        funnel.destroy!
      end
    end
  end
end
