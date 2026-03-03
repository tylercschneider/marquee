require "test_helper"

module Marquee
  class VersionTest < ActiveSupport::TestCase
    test "belongs to a versionable (polymorphic)" do
      page = Marquee::Page.create!(title: "Test", slug: "ver-poly")
      version = Marquee::Version.create!(
        versionable: page,
        action: "created",
        snapshot: page.attributes.except("created_at", "updated_at")
      )
      assert_equal page, version.versionable
    end

    test "auto-creates version on page create" do
      page = Marquee::Page.create!(title: "Versioned", slug: "ver-create")
      assert_equal 1, page.versions.count
      version = page.versions.last
      assert_equal "created", version.action
      assert version.snapshot.key?("title")
    end
  end
end
