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

  test "define_page accepts template_path" do
    Marquee.define_page :about do
      title "About"
      template_path "marquee_pages/about"
    end

    defn = Marquee::PageDefinition.registry[:about]
    assert_equal "marquee_pages/about", defn.template_path
  end

  test "sync! creates pages in database with metadata only" do
    Marquee.define_page :about do
      title "About Us"
      page_type :about
      template_path "marquee_pages/about"
      meta_title "About - TestApp"
      meta_description "Learn about us"
    end

    Marquee::PageDefinition.sync!

    page = Marquee::Page.find_by(slug: "about")
    assert_not_nil page
    assert_equal "About Us", page.title
    assert_equal "about", page.page_type
    assert_equal "marquee_pages/about", page.template_path
    assert_equal "About - TestApp", page.meta_title
    assert_equal "Learn about us", page.meta_description
  end

  test "sync! upserts existing pages" do
    Marquee::Page.create!(title: "Old Title", slug: "pricing")

    Marquee.define_page :pricing do
      title "New Pricing"
      page_type :pricing
      template_path "marquee_pages/pricing"
    end

    Marquee::PageDefinition.sync!

    page = Marquee::Page.find_by(slug: "pricing")
    assert_equal "New Pricing", page.title
    assert_equal "marquee_pages/pricing", page.template_path
    assert_equal 1, Marquee::Page.where(slug: "pricing").count
  end
end
