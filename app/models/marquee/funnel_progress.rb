module Marquee
  class FunnelProgress < ApplicationRecord
    belongs_to :funnel_step

    validates :visitor_token, presence: true
  end
end
