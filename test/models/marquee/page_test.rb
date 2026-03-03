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

    test "publish! sets status to published and published_at" do
      page = Marquee::Page.create!(title: "Test", slug: "pub-test")
      assert_equal "draft", page.status

      page.publish!
      assert_equal "published", page.status
      assert_not_nil page.published_at
    end

    test "published scope returns only published pages" do
      draft = Marquee::Page.create!(title: "Draft", slug: "draft-page")
      published = Marquee::Page.create!(title: "Published", slug: "published-page")
      published.publish!

      results = Marquee::Page.published
      assert_includes results, published
      assert_not_includes results, draft
    end
  end
end
