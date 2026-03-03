require "test_helper"

class Marquee::ConfigurationTest < ActiveSupport::TestCase
  test "has default site_name" do
    config = Marquee::Configuration.new
    assert_equal "My Site", config.site_name
  end

  test "configure block sets values" do
    Marquee.configure do |config|
      config.site_name = "TestApp"
    end
    assert_equal "TestApp", Marquee.configuration.site_name
  ensure
    Marquee.instance_variable_set(:@configuration, nil)
  end

  test "has sensible defaults for all options" do
    config = Marquee::Configuration.new
    assert_equal "/", config.public_path
    assert_equal "/admin/site", config.admin_path
    assert_nil config.admin_auth
    assert_nil config.current_user_method
    assert_equal true, config.enable_tracking
  end
end
