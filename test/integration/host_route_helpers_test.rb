require "test_helper"

class HostRouteHelpersTest < ActiveSupport::TestCase
  test "controllers outside marquee are not given the host's route helpers" do
    assert_not ActionController::Base._helpers.include?(Rails.application.routes.url_helpers)
  end
end
