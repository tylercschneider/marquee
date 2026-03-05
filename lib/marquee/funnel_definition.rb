module Marquee
  class FunnelDefinition
    attr_reader :slug, :steps

    def self.registry
      @registry ||= {}
    end

    def self.sync!
      registry.each_value do |defn|
        funnel = Funnel.find_or_initialize_by(slug: defn.slug)
        funnel.update!(name: defn.funnel_name)

        defn.steps.each do |step_def|
          page = Page.find_by!(slug: step_def[:page_slug].to_s)
          step = funnel.funnel_steps.find_or_initialize_by(position: step_def[:position])
          step.update!(page: page, label: step_def[:label])
        end

        # Remove steps no longer in DSL
        defined_positions = defn.steps.map { |s| s[:position] }
        funnel.funnel_steps.where.not(position: defined_positions).destroy_all
      end
    end

    def initialize(slug, &block)
      @slug = slug.to_s
      @_name = nil
      @steps = []
      instance_eval(&block) if block
    end

    def name(value = nil)
      value ? @_name = value : @_name
    end

    def funnel_name
      @_name
    end

    def step(page_slug, label:, position:)
      @steps << { page_slug: page_slug, label: label, position: position }
    end
  end
end
