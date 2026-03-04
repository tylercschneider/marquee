module Marquee
  class PagesController < ApplicationController
    def show
      @page = Marquee::Page.published.find_by!(slug: params[:slug])
      render template: @page.template_path
    end
  end
end
