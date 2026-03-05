require "test_helper"

module Marquee
  class VisitorIdentityTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      Marquee::Page.create!(
        title: "Identity Test", slug: "identity-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
    end

    test "sets marquee_vid cookie on first visit" do
      get "/identity-test"
      assert_response :success
      assert cookies[:marquee_vid].present?, "Expected marquee_vid cookie to be set"
    end

    test "marquee_vid cookie is a valid UUID" do
      get "/identity-test"
      uuid = cookies[:marquee_vid]
      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, uuid)
    end

    test "marquee_vid cookie persists across requests" do
      get "/identity-test"
      first_vid = cookies[:marquee_vid]

      get "/identity-test"
      second_vid = cookies[:marquee_vid]

      assert_equal first_vid, second_vid
    end
  end
end
