module Marquee
  class PagesController < ApplicationController
    def show
      @page = Marquee::Page.published.find_by!(slug: params[:slug])
      @experiment = @page.experiments.running.first
      template = resolve_template

      event_properties = { page_id: @page.id, slug: @page.slug }
      if @variant
        event_properties[:experiment_id] = @experiment.id
        event_properties[:variant_id] = @variant.id
      end

      Marquee.instrument("page.viewed", **event_properties)
      render template: template
    end

    private

    def resolve_template
      if @experiment
        @variant = VariantAssigner.new.call(@experiment, visitor_token)
        @variant.template_path
      else
        @page.template_path
      end
    end
  end
end
