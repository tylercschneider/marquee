require "test_helper"

module Marquee
  class SectionTest < ActiveSupport::TestCase
    test "belongs to a page" do
      page = Marquee::Page.create!(title: "Test", slug: "sec-page")
      section = Marquee::Section.create!(page: page, section_type: "hero", position: 0)
      assert_equal page, section.page
    end

    test "rejects invalid section_type" do
      page = Marquee::Page.create!(title: "Test", slug: "sec-type")
      section = Marquee::Section.new(page: page, section_type: "bogus", position: 0)
      assert_not section.valid?
      assert_includes section.errors[:section_type], "is not included in the list"
    end
  end
end
