require "test_helper"

class Marquee::DslTest < ActiveSupport::TestCase
  teardown do
    Marquee::PageDefinition.registry.clear
  end

  test "define_page registers a page definition" do
    Marquee.define_page :pricing do
      title "Pricing"
      page_type :pricing
    end

    assert_equal 1, Marquee::PageDefinition.registry.size
    defn = Marquee::PageDefinition.registry[:pricing]
    assert_equal "Pricing", defn.title
    assert_equal "pricing", defn.page_type
  end

  test "define_page with sections" do
    Marquee.define_page :landing do
      title "Landing"
      hero headline: "Welcome", subheadline: "Get started"
      cta headline: "Ready?", cta_text: "Sign Up"
    end

    defn = Marquee::PageDefinition.registry[:landing]
    assert_equal 2, defn.sections.size
    assert_equal "hero", defn.sections[0][:type]
    assert_equal "Welcome", defn.sections[0][:content]["headline"]
    assert_equal "cta", defn.sections[1][:type]
  end
end
