module Marquee
  class PagesController < ApplicationController
    def show
      @page = Marquee::Page.published.find_by!(slug: params[:slug])
      @sections = @page.sections.visible
    end
  end
end
