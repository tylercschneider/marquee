require "test_helper"

module Marquee
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "GET /:slug renders a published page" do
      Marquee::Page.create!(title: "About Us", slug: "about", status: "published", published_at: Time.current)

      get "/marquee/about"
      assert_response :success
      assert_match "About Us", response.body
    end

    test "GET /:slug returns 404 for draft page" do
      Marquee::Page.create!(title: "Draft", slug: "draft-page")

      get "/marquee/draft-page"
      assert_response :not_found
    end

    test "GET /:slug includes SEO meta tags" do
      Marquee::Page.create!(
        title: "About", slug: "about-seo", status: "published", published_at: Time.current,
        meta_title: "About Us - TestApp", meta_description: "Learn about us"
      )

      get "/marquee/about-seo"
      assert_response :success
      assert_match "About Us - TestApp", response.body
      assert_match "Learn about us", response.body
    end
  end
end
