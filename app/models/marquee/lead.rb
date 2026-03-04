module Marquee
  class Lead < ApplicationRecord
    STATUSES = %w[new contacted converted unsubscribed].freeze

    belongs_to :source_page, class_name: "Marquee::Page"

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :status, inclusion: { in: STATUSES }
  end
end
