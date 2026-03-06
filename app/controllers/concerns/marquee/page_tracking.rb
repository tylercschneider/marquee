module Marquee
  module PageTracking
    extend ActiveSupport::Concern

    include Marquee::VisitorIdentity

    private

    def track_marquee_page(slug)
      @page = Marquee::Page.published.find_by(slug: slug)
      return unless @page

      @experiment = @page.experiments.running.first

      if @experiment
        @variant = Marquee::VariantAssigner.new.call(@experiment, visitor_token)
      end

      event_properties = { page_id: @page.id, slug: @page.slug }
      if @variant
        event_properties[:experiment_id] = @experiment.id
        event_properties[:variant_id] = @variant.id
      end

      Marquee.instrument("page.viewed", **event_properties)
      record_funnel_progress
    end

    def record_funnel_progress
      @page.funnel_steps.find_each do |step|
        Marquee::FunnelProgress.find_or_create_by(funnel_step: step, visitor_token: visitor_token)
      end
    end
  end
end
