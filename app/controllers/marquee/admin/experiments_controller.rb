module Marquee
  module Admin
    class ExperimentsController < BaseController
      def index
        @experiments = Marquee::Experiment.includes(:page).order(created_at: :desc)
      end

      def show
        @experiment = Marquee::Experiment.find(params[:id])
        @results = @experiment.results
      end
    end
  end
end
