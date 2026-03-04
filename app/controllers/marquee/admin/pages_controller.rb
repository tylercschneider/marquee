module Marquee
  module Admin
    class PagesController < BaseController
      def index
        @pages = Marquee::Page.order(position: :asc, created_at: :desc)
      end
    end
  end
end
