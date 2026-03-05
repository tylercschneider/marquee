module Marquee
  class FunnelStep < ApplicationRecord
    belongs_to :funnel
    belongs_to :page

    has_many :progresses, class_name: "Marquee::FunnelProgress", dependent: :destroy

    validates :position, presence: true, uniqueness: { scope: :funnel_id }
    validates :label, presence: true
  end
end
