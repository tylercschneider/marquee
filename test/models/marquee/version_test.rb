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

    test "auto-creates version on page update with changeset" do
      page = Marquee::Page.create!(title: "Original", slug: "ver-update")
      page.update!(title: "Updated")
      versions = page.versions.order(:created_at)
      assert_equal 2, versions.count
      assert_equal "updated", versions.last.action
      assert_equal({ "title" => [ "Original", "Updated" ] }, versions.last.changeset)
    end

    test "records published action when page is published" do
      page = Marquee::Page.create!(title: "Pub", slug: "ver-pub")
      page.publish!
      assert_equal "published", page.versions.order(:created_at).last.action
    end

    test "auto-creates version on section create" do
      page = Marquee::Page.create!(title: "Page", slug: "sec-ver")
      section = Marquee::Section.create!(page: page, section_type: "hero", position: 0)
      assert_equal 1, section.versions.count
      assert_equal "created", section.versions.last.action
    end
  end
end
