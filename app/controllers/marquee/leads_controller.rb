module Marquee
  class LeadsController < ApplicationController
    include Marquee::LeadCapture

    def create
      @lead = capture_marquee_lead(lead_params)

      if @lead.persisted?
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
  end
end
