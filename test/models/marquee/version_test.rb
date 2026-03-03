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
  end
end
