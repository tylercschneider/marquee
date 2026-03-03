module Marquee
  class Page < ApplicationRecord
    validates :title, presence: true
    validates :slug, uniqueness: true
  end
end
