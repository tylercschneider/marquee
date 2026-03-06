class LeadCaptureTestController < ApplicationController
  include Marquee::LeadCapture

  def create
    lead = capture_marquee_lead(lead_params)

    if lead.persisted?
      render plain: "OK"
    else
      render plain: "FAIL", status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:email, :name, :source_page_id, data: {})
  end
end
