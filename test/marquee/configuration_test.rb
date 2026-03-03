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
end
