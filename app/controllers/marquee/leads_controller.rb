module Marquee
  class LeadsController < ApplicationController
    def create
      @lead = Lead.new(lead_params)
      @lead.visitor_token = visitor_token

      if @lead.save
        Marquee.instrument("lead.created", email: @lead.email, page_id: @lead.source_page_id)
        redirect_to page_path(@lead.source_page.slug)
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
