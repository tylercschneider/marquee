module Marquee
  class Version < ApplicationRecord
    ACTIONS = %w[created updated published unpublished archived rolled_back].freeze

    belongs_to :versionable, polymorphic: true

    validates :action, inclusion: { in: ACTIONS }
  end
end
