module Marquee
  class Page < ApplicationRecord
    validates :title, presence: true
  end
end
