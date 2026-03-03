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
        action: determine_update_action,
        changeset: saved_changes.except("created_at", "updated_at"),
        snapshot: attributes.except("created_at", "updated_at")
      )
    end

    def determine_update_action
      if saved_change_to_attribute?("status")
        case status
        when "published" then "published"
        when "archived" then "archived"
        when "draft" then status_before_last_save == "published" ? "unpublished" : "updated"
        else "updated"
        end
      else
        "updated"
      end
    end
  end
end
