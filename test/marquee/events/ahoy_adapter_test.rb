require "test_helper"

class Marquee::Events::AhoyAdapterTest < ActiveSupport::TestCase
  test "raises error when ahoy is not defined" do
    adapter = Marquee::Events::AhoyAdapter.new

    error = assert_raises(Marquee::Events::AhoyAdapter::AhoyNotInstalled) do
      adapter.track("page.viewed", slug: "pricing")
    end

    assert_match(/ahoy_matey/, error.message)
  end

  test "delegates to Ahoy::Tracker when ahoy is available" do
    tracked = []

    fake_tracker_class = Class.new do
      define_method(:initialize) { |**_| }
      define_method(:track) { |name, props| tracked << [ name, props ] }
    end

    Object.const_set(:Ahoy, Module.new)
    Ahoy.const_set(:Tracker, fake_tracker_class)

    adapter = Marquee::Events::AhoyAdapter.new
    adapter.track("page.viewed", slug: "pricing")

    assert_equal 1, tracked.size
    assert_equal "page.viewed", tracked[0][0]
    assert_equal({ slug: "pricing" }, tracked[0][1])
  ensure
    Object.send(:remove_const, :Ahoy) if defined?(Ahoy)
  end
end
