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
end
