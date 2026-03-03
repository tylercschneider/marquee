require "test_helper"

module Marquee
  class SectionTest < ActiveSupport::TestCase
    test "belongs to a page" do
      page = Marquee::Page.create!(title: "Test", slug: "sec-page")
      section = Marquee::Section.create!(page: page, section_type: "hero", position: 0)
      assert_equal page, section.page
    end
  end
end
