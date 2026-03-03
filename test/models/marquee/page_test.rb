require "test_helper"

module Marquee
  class PageTest < ActiveSupport::TestCase
    test "requires a title" do
      page = Marquee::Page.new(title: nil, slug: "test")
      assert_not page.valid?
      assert_includes page.errors[:title], "can't be blank"
    end
  end
end
