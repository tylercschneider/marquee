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

    test "records published action when page is published" do
      page = Marquee::Page.create!(title: "Pub", slug: "ver-pub")
      page.publish!
      assert_equal "published", page.versions.order(:created_at).last.action
    end

    test "deployed is a valid version action" do
      page = Marquee::Page.create!(title: "Test", slug: "ver-deploy")
      version = page.versions.create!(action: "deployed", snapshot: {})
      assert version.valid?
    end

    test "bump_version! creates deployed version with label" do
      page = Marquee::Page.create!(title: "Test", slug: "ver-bump")
      page.bump_version!("v1.2.0")

      assert_equal "v1.2.0", page.current_version
      deploy_version = page.versions.where(action: "deployed").last
      assert_not_nil deploy_version
      assert_equal({ "current_version" => "v1.2.0" }, deploy_version.changeset)
    end

    test "record_version! creates explicit version" do
      page = Marquee::Page.create!(title: "Test", slug: "ver-explicit")
      page.record_version!("updated", changeset: { "title" => %w[Old New] })

      version = page.versions.order(:created_at).last
      assert_equal "updated", version.action
      assert_equal({ "title" => %w[Old New] }, version.changeset)
    end
  end
end
