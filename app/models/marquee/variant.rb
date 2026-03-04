module Marquee
  class Variant < ApplicationRecord
    belongs_to :experiment

    validates :name, presence: true
    validates :template_path, presence: true
  end
end
