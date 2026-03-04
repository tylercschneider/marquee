module Marquee
  module Admin
    class LeadsController < BaseController
      def index
        @leads = Marquee::Lead.includes(:source_page).order(created_at: :desc)
      end
    end
  end
end
