module Marquee
  class VariantAssigner
    def call(experiment, visitor_token)
      existing = experiment.assignments.find_by(visitor_token: visitor_token)
      return existing.variant if existing

      variants = experiment.variants.to_a
      total = variants.sum(&:weight)
      roll = rand(total)
      selected = variants.detect { |v| (roll -= v.weight) < 0 }

      experiment.assignments.create!(
        variant: selected,
        visitor_token: visitor_token,
        assigned_at: Time.current
      )
      selected
    end
  end
end
