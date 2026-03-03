module Marquee
  class Page < ApplicationRecord
    validates :title, presence: true
    validates :slug, uniqueness: true,
                     format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                               message: "only allows lowercase letters, numbers, and hyphens" }
  end
end
