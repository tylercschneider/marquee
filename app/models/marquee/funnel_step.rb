module Marquee
  class FunnelStep < ApplicationRecord
    belongs_to :funnel
    belongs_to :page

    validates :position, presence: true, uniqueness: { scope: :funnel_id }
    validates :label, presence: true
  end
end
