module Marquee
  class Funnel < ApplicationRecord
    STATUSES = %w[draft published archived].freeze

    has_many :funnel_steps, dependent: :destroy
    has_many :pages, through: :funnel_steps

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUSES }

    def results
      steps = funnel_steps.includes(:page).order(:position)
      previous_visitors = nil

      steps.map do |step|
        visitors = step.progresses.distinct.count(:visitor_token)
        drop_off_rate = if previous_visitors.nil? || previous_visitors == 0
          0.0
        else
          ((1 - (visitors.to_f / previous_visitors)) * 100).round(2)
        end
        previous_visitors = visitors

        {
          position: step.position,
          label: step.label,
          page_slug: step.page.slug,
          visitors: visitors,
          drop_off_rate: drop_off_rate
        }
      end
    end
  end
end
