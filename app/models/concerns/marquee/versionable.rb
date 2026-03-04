module Marquee
  module Versionable
    extend ActiveSupport::Concern

    included do
      has_many :versions, as: :versionable, class_name: "Marquee::Version", dependent: :destroy

      after_create :create_created_version
    end

    def record_version!(action, changeset: {})
      versions.create!(
        action: action,
        changeset: changeset,
        snapshot: attributes.except("created_at", "updated_at")
      )
    end

    private

    def create_created_version
      versions.create!(
        action: "created",
        snapshot: attributes.except("created_at", "updated_at")
      )
    end
  end
end
