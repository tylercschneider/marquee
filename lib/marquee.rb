require "marquee/version"
require "marquee/configuration"
require "marquee/engine"

module Marquee
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
