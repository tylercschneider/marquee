module Marquee
  module Admin
    class FunnelsController < BaseController
      def index
        @funnels = Marquee::Funnel.order(created_at: :desc)
      end

      def show
        @funnel = Marquee::Funnel.find(params[:id])
        @results = @funnel.results
      end
    end
  end
end
