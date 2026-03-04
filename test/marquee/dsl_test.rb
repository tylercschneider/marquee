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

  test "sync! creates pages and sections in database" do
    Marquee.define_page :about do
      title "About Us"
      page_type :about
      hero headline: "Our Story"
    end

    Marquee::PageDefinition.sync!

    page = Marquee::Page.find_by(slug: "about")
    assert_not_nil page
    assert_equal "About Us", page.title
    assert_equal "about", page.page_type
    assert_equal 1, page.sections.count
    assert_equal "Our Story", page.sections.first.content["headline"]
  end
end
