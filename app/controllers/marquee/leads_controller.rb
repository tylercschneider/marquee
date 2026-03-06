module Marquee
  class LeadsController < ApplicationController
    def create
      @lead = Lead.new(lead_params)
      @lead.visitor_token = visitor_token
      record_conversion(@lead)

      if @lead.save
        Marquee.instrument("lead.created", email: @lead.email, page_id: @lead.source_page_id)
        Marquee.configuration.on_lead_created&.call(@lead)
        redirect_to main_app.marquee_page_path(@lead.source_page.slug)
      else
        @page = @lead.source_page
        render template: @page.template_path, status: :unprocessable_entity
      end
    end

    private

    def lead_params
      params.require(:lead).permit(:email, :name, :source_page_id, data: {})
    end

    def record_conversion(lead)
      return unless lead.source_page

      experiment = lead.source_page.experiments.running.first
      return unless experiment

      assignment = experiment.assignments.find_by(visitor_token: lead.visitor_token)
      return unless assignment

      lead.converted_experiment_id = experiment.id
      lead.converted_variant_id = assignment.variant_id
    end
  end
end
