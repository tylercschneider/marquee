module Marquee
  class Funnel < ApplicationRecord
    STATUSES = %w[draft published archived].freeze

    has_many :funnel_steps, dependent: :destroy
    has_many :pages, through: :funnel_steps

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUSES }
  end
end
