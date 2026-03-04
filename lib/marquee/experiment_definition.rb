module Marquee
  class ExperimentDefinition
    attr_reader :name, :variants

    def initialize(name, &block)
      @name = name
      @_metric = "lead_capture"
      @variants = []
      instance_eval(&block) if block
    end

    def metric(value = nil)
      value ? @_metric = value.to_s : @_metric
    end

    def variant(name, template_path:, control: false, weight: 1)
      @variants << { name: name, template_path: template_path, control: control, weight: weight }
    end
  end
end
