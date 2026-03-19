require "test_helper"

class HostRoutesTest < ActionDispatch::IntegrationTest
  setup do
    @page = Marquee::Page.create!(
      title: "Test", slug: "host-route-test", status: "published",
      published_at: Time.current, template_path: "marquee_pages/test_page"
    )
  end

  test "admin layout back link points to host app root" do
    get "/admin/marquee/experiments"
    assert_response :success
    assert_includes response.body, 'href="/"'
  end

  test "admin nav links use marquee engine prefix" do
    get "/admin/marquee/experiments"
    assert_response :success
    assert_includes response.body, 'href="/admin/marquee/experiments"'
    assert_includes response.body, 'href="/admin/marquee/funnels"'
    assert_includes response.body, 'href="/admin/marquee/leads"'
    assert_includes response.body, 'href="/admin/marquee/pages"'
  end
end
