module Marquee
  class Experiment < ApplicationRecord
    STATUSES = %w[draft running paused completed].freeze

    belongs_to :page
    has_many :variants, dependent: :destroy

    validates :name, presence: true
    validates :status, inclusion: { in: STATUSES }

    scope :running, -> { where(status: "running") }
  end
end
