module Marquee
  class Assignment < ApplicationRecord
    belongs_to :experiment
    belongs_to :variant

    validates :visitor_token, presence: true, uniqueness: { scope: :experiment_id }
    validates :assigned_at, presence: true
  end
end
