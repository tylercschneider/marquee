require "marquee/version"
require "marquee/configuration"
require "marquee/page_definition"
require "marquee/engine"

module Marquee
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.define_page(slug, &block)
    defn = PageDefinition.new(slug, &block)
    PageDefinition.registry[slug.to_sym] = defn
  end
end
