require "test_helper"

module Marquee
  class PageTest < ActiveSupport::TestCase
    test "requires a title" do
      page = Marquee::Page.new(title: nil, slug: "test")
      assert_not page.valid?
      assert_includes page.errors[:title], "can't be blank"
    end

    test "requires a unique slug" do
      Marquee::Page.create!(title: "First", slug: "taken")
      page = Marquee::Page.new(title: "Second", slug: "taken")
      assert_not page.valid?
      assert_includes page.errors[:slug], "has already been taken"
    end

    test "rejects slugs with invalid characters" do
      page = Marquee::Page.new(title: "Test", slug: "no spaces!")
      assert_not page.valid?
      assert_includes page.errors[:slug], "only allows lowercase letters, numbers, and hyphens"
    end

    test "rejects invalid status" do
      page = Marquee::Page.new(title: "Test", slug: "test", status: "bogus")
      assert_not page.valid?
      assert_includes page.errors[:status], "is not included in the list"
    end

    test "rejects invalid page_type" do
      page = Marquee::Page.new(title: "Test", slug: "test", page_type: "bogus")
      assert_not page.valid?
      assert_includes page.errors[:page_type], "is not included in the list"
    end
  end
end
