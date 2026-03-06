module Marquee
  class PagesController < ApplicationController
    include Marquee::PageTracking

    def show
      track_marquee_page(params[:slug])
      template = @variant ? @variant.template_path : @page.template_path
      render template: template
    end
  end
end
