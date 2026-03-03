module Marquee
  class Page < ApplicationRecord
    include Marquee::Versionable

    STATUSES = %w[draft published archived].freeze
    PAGE_TYPES = %w[homepage landing feature pricing about legal custom].freeze

    has_many :sections, -> { order(:position) }, dependent: :destroy

    scope :published, -> { where(status: "published") }

    validates :title, presence: true
    validates :status, inclusion: { in: STATUSES }
    validates :page_type, inclusion: { in: PAGE_TYPES }
    validates :slug, uniqueness: true,
                     format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                               message: "only allows lowercase letters, numbers, and hyphens" }

    def publish!
      update!(status: "published", published_at: Time.current)
    end
  end
end
