require "test_helper"

class Marquee::EventsTest < ActiveSupport::TestCase
  test "BaseAdapter#track raises NotImplementedError" do
    adapter = Marquee::Events::BaseAdapter.new
    assert_raises(NotImplementedError) { adapter.track("test.event") }
  end

  test "LogAdapter#track logs the event" do
    adapter = Marquee::Events::LogAdapter.new
    output = StringIO.new
    Rails.logger = ActiveSupport::Logger.new(output)

    adapter.track("page.viewed", slug: "pricing")

    assert_match "page.viewed", output.string
    assert_match "pricing", output.string
  ensure
    Rails.logger = ActiveSupport::Logger.new($stdout)
  end

  test "NullAdapter#track does nothing" do
    adapter = Marquee::Events::NullAdapter.new
    assert_nil adapter.track("page.viewed", slug: "pricing")
  end

  test "Marquee.instrument delegates to configured adapter" do
    calls = []
    custom_adapter = Class.new(Marquee::Events::BaseAdapter) do
      define_method(:track) { |event_name, properties| calls << [ event_name, properties ] }
    end.new

    original = Marquee.configuration.event_adapter
    Marquee.configuration.event_adapter = custom_adapter

    Marquee.instrument("page.viewed", slug: "about")

    assert_equal 1, calls.size
    assert_equal "page.viewed", calls[0][0]
    assert_equal({ slug: "about" }, calls[0][1])
  ensure
    Marquee.configuration.event_adapter = original
  end
end
