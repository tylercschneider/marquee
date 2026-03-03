module Marquee
  class Section < ApplicationRecord
    include Marquee::Versionable

    SECTION_TYPES = %w[hero features pricing_table testimonials faq cta form
                       text_block image_block custom_html announcement_bar
                       social_proof team stats comparison video logo_cloud].freeze

    belongs_to :page

    scope :visible, -> { where(visible: true) }

    validates :section_type, inclusion: { in: SECTION_TYPES }
  end
end
