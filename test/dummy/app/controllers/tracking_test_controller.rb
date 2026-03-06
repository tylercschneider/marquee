class TrackingTestController < ApplicationController
  include Marquee::PageTracking

  def show
    track_marquee_page(params[:slug])
    render plain: "OK"
  end
end
