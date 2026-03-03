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
  end
end
