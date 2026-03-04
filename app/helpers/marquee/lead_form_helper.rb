module Marquee
  module LeadFormHelper
    def marquee_lead_form(page:, **options, &block)
      form_with(
        model: Marquee::Lead.new,
        url: marquee.leads_path,
        **options
      ) do |f|
        concat f.hidden_field(:source_page_id, value: page.id)
        yield f if block_given?
      end
    end
  end
end
