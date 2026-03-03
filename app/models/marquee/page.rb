module Marquee
  class Page < ApplicationRecord
    STATUSES = %w[draft published archived].freeze

    validates :title, presence: true
    validates :status, inclusion: { in: STATUSES }
    validates :slug, uniqueness: true,
                     format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                               message: "only allows lowercase letters, numbers, and hyphens" }
  end
end
