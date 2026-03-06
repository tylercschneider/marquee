module Marquee
  module LeadCapture
    extend ActiveSupport::Concern

    include Marquee::VisitorIdentity

    private

    def capture_marquee_lead(params)
      lead = Marquee::Lead.new(params)
      lead.visitor_token = visitor_token
      record_conversion(lead)

      if lead.save
        Marquee.instrument("lead.created", email: lead.email, page_id: lead.source_page_id)
        Marquee.configuration.on_lead_created&.call(lead)
      end

      lead
    end

    def record_conversion(lead)
      return unless lead.source_page

      experiment = lead.source_page.experiments.running.first
      return unless experiment

      assignment = experiment.assignments.find_by(visitor_token: lead.visitor_token)
      return unless assignment

      lead.converted_experiment_id = experiment.id
      lead.converted_variant_id = assignment.variant_id
    end
  end
end
