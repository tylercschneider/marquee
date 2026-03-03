require "test_helper"

class Marquee::ConfigurationTest < ActiveSupport::TestCase
  test "has default site_name" do
    config = Marquee::Configuration.new
    assert_equal "My Site", config.site_name
  end
end
