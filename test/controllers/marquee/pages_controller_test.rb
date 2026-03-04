require "test_helper"

module Marquee
  class PagesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "GET /:slug renders the page template_path" do
      Marquee::Page.create!(
        title: "Test Page", slug: "test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )

      get "/marquee/test"
      assert_response :success
      assert_match "Test Page", response.body
      assert_match "Test page content", response.body
    end

    test "GET /:slug returns 404 for draft page" do
      Marquee::Page.create!(title: "Draft", slug: "draft-page", template_path: "marquee_pages/test_page")

      get "/marquee/draft-page"
      assert_response :not_found
    end

    test "GET /:slug includes SEO meta tags from layout" do
      Marquee::Page.create!(
        title: "About", slug: "about-seo", status: "published", published_at: Time.current,
        template_path: "marquee_pages/test_page",
        meta_title: "About Us - TestApp", meta_description: "Learn about us"
      )

      get "/marquee/about-seo"
      assert_response :success
      assert_match "About Us - TestApp", response.body
      assert_match "Learn about us", response.body
    end
  end
end
