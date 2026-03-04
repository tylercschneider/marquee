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

      def start
        experiment = Marquee::Experiment.find(params[:id])
        experiment.start!
        redirect_to admin_experiment_path(experiment), notice: "Experiment started."
      end

      def pause
        experiment = Marquee::Experiment.find(params[:id])
        experiment.pause!
        redirect_to admin_experiment_path(experiment), notice: "Experiment paused."
      end

      def resume
        experiment = Marquee::Experiment.find(params[:id])
        experiment.resume!
        redirect_to admin_experiment_path(experiment), notice: "Experiment resumed."
      end

      def complete
        experiment = Marquee::Experiment.find(params[:id])
        experiment.complete!
        redirect_to admin_experiment_path(experiment), notice: "Experiment completed."
      end
    end
  end
end
