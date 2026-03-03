require "test_helper"

module Marquee
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "GET /:slug renders a published page" do
      page = Marquee::Page.create!(title: "About Us", slug: "about", status: "published", published_at: Time.current)
      Marquee::Section.create!(page: page, section_type: "hero", position: 0,
                               content: { "headline" => "Welcome" })

      get "/marquee/about"
      assert_response :success
      assert_match "Welcome", response.body
    end

    test "GET /:slug returns 404 for draft page" do
      Marquee::Page.create!(title: "Draft", slug: "draft-page")

      get "/marquee/draft-page"
      assert_response :not_found
    end
  end
end
