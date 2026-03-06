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
    assert_equal "published", page.status
    assert_not_nil page.published_at
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

  test "sync! with version creates deployed version on existing pages" do
    Marquee::Page.create!(title: "Pricing", slug: "pricing")

    Marquee.define_page :pricing do
      title "Pricing"
      page_type :pricing
      template_path "marquee_pages/pricing"
    end

    Marquee::PageDefinition.sync!(version: "v2.0.0")

    page = Marquee::Page.find_by(slug: "pricing")
    assert_equal "v2.0.0", page.current_version
    assert_equal "deployed", page.versions.where(action: "deployed").last.action
  end

  test "sync! with version does not create deployed version on new pages" do
    Marquee.define_page :"new-page" do
      title "New Page"
      template_path "marquee_pages/new"
    end

    Marquee::PageDefinition.sync!(version: "v1.0.0")

    page = Marquee::Page.find_by(slug: "new-page")
    assert_not_nil page
    assert_nil page.current_version
    assert_equal 0, page.versions.where(action: "deployed").count
  end

  test "define_page with experiment block registers experiment definitions" do
    Marquee.define_page :pricing do
      title "Pricing"
      template_path "marquee_pages/pricing"

      experiment "Hero headline test" do
        metric :lead_capture
        variant "Control", template_path: "marquee_pages/pricing", control: true
        variant "Short headline", template_path: "marquee_pages/pricing_v2"
      end
    end

    defn = Marquee::PageDefinition.registry[:pricing]
    assert_equal 1, defn.experiments.size

    exp = defn.experiments.first
    assert_equal "Hero headline test", exp.name
    assert_equal "lead_capture", exp.metric
    assert_equal 2, exp.variants.size

    control = exp.variants.find { |v| v[:name] == "Control" }
    assert control[:control]
    assert_equal "marquee_pages/pricing", control[:template_path]

    variant_b = exp.variants.find { |v| v[:name] == "Short headline" }
    assert_not variant_b[:control]
    assert_equal "marquee_pages/pricing_v2", variant_b[:template_path]
  end

  test "sync! creates experiments and variants in database" do
    Marquee.define_page :pricing do
      title "Pricing"
      template_path "marquee_pages/pricing"

      experiment "Hero test" do
        metric :lead_capture
        variant "Control", template_path: "marquee_pages/pricing", control: true
        variant "Variant B", template_path: "marquee_pages/pricing_v2", weight: 2
      end
    end

    Marquee::PageDefinition.sync!

    page = Marquee::Page.find_by(slug: "pricing")
    assert_equal 1, page.experiments.count

    exp = page.experiments.first
    assert_equal "Hero test", exp.name
    assert_equal "lead_capture", exp.metric
    assert_equal "draft", exp.status
    assert_equal 2, exp.variants.count

    control = exp.variants.find_by(name: "Control")
    assert control.is_control
    assert_equal "marquee_pages/pricing", control.template_path
    assert_equal 1, control.weight

    variant_b = exp.variants.find_by(name: "Variant B")
    assert_not variant_b.is_control
    assert_equal "marquee_pages/pricing_v2", variant_b.template_path
    assert_equal 2, variant_b.weight
  end

  test "sync! upserts experiments by name" do
    Marquee.define_page :pricing do
      title "Pricing"
      template_path "marquee_pages/pricing"

      experiment "Hero test" do
        variant "Control", template_path: "marquee_pages/pricing", control: true
      end
    end

    Marquee::PageDefinition.sync!
    Marquee::PageDefinition.sync!

    page = Marquee::Page.find_by(slug: "pricing")
    assert_equal 1, page.experiments.count
    assert_equal 1, page.experiments.first.variants.count
  end
end
