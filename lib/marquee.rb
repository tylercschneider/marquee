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
  # Returns the current configuration instance.
  # @return [Marquee::Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Yields the configuration instance for modification.
  # @yieldparam config [Marquee::Configuration]
  # @example
  #   Marquee.configure do |config|
  #     config.site_name = "My App"
  #     config.event_adapter = Marquee::Events::AhoyAdapter.new
  #   end
  def self.configure
    yield(configuration)
  end

  # Registers a page definition. Call +PageDefinition.sync!+ to persist to the database.
  # @param slug [String, Symbol] unique page identifier (becomes the URL slug)
  # @yieldparam definition [Marquee::PageDefinition] block to configure title, template_path, SEO, experiments
  # @return [Marquee::PageDefinition]
  def self.define_page(slug, &block)
    defn = PageDefinition.new(slug, &block)
    PageDefinition.registry[slug.to_sym] = defn
  end

  # Registers a funnel definition. Synced to the database when +PageDefinition.sync!+ is called.
  # @param slug [String, Symbol] unique funnel identifier
  # @yieldparam definition [Marquee::FunnelDefinition] block to configure name and steps
  # @return [Marquee::FunnelDefinition]
  def self.define_funnel(slug, &block)
    defn = FunnelDefinition.new(slug, &block)
    FunnelDefinition.registry[slug.to_sym] = defn
  end

  # Draws public Marquee routes (pages, leads) into the host application's router.
  # Call this in your host app's +config/routes.rb+ to add public routes at the top level.
  # @param router [ActionDispatch::Routing::RouteSet] the host app's route context (pass +self+)
  # @example
  #   # config/routes.rb
  #   Rails.application.routes.draw do
  #     mount Marquee::Engine => "/admin/marquee"
  #     Marquee.routes(self)
  #   end
  def self.routes(router)
    router.instance_exec do
      resources :leads, only: :create, controller: "marquee/leads"
      get "/:slug", to: "marquee/pages#show", as: :marquee_page
    end
  end

  # Sends an event through the configured event adapter.
  # @param event_name [String] the event name (e.g. "page.viewed", "lead.created")
  # @param properties [Hash] arbitrary event properties
  def self.instrument(event_name, **properties)
    configuration.event_adapter.track(event_name, properties)
  end
end
