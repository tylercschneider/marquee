require "marquee/version"
require "marquee/events/base_adapter"
require "marquee/events/log_adapter"
require "marquee/events/null_adapter"
require "marquee/events/ahoy_adapter"
require "marquee/configuration"
require "marquee/experiment_definition"
require "marquee/funnel_definition"
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

  def self.define_funnel(slug, &block)
    defn = FunnelDefinition.new(slug, &block)
    FunnelDefinition.registry[slug.to_sym] = defn
  end

  def self.instrument(event_name, **properties)
    configuration.event_adapter.track(event_name, properties)
  end
end
