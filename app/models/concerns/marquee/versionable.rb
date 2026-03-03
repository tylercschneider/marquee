module Marquee
  module Versionable
    extend ActiveSupport::Concern

    included do
      has_many :versions, as: :versionable, class_name: "Marquee::Version", dependent: :destroy

      after_create :create_created_version
      after_update :create_updated_version
    end

    private

    def create_created_version
      versions.create!(
        action: "created",
        snapshot: attributes.except("created_at", "updated_at")
      )
    end

    def create_updated_version
      versions.create!(
        action: "updated",
        changeset: saved_changes.except("created_at", "updated_at"),
        snapshot: attributes.except("created_at", "updated_at")
      )
    end
  end
end
