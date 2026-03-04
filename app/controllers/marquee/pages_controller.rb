module Marquee
  class PagesController < ApplicationController
    def show
      @page = Marquee::Page.published.find_by!(slug: params[:slug])
      Marquee.instrument("page.viewed", page_id: @page.id, slug: @page.slug)
      render template: @page.template_path
    end
  end
end
