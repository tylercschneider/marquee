require "test_helper"

module Marquee
  class ExperimentResultsTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test", slug: "results-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @experiment = Marquee::Experiment.create!(name: "Results Test", page: @page, status: "running", started_at: Time.current)
      @control = Marquee::Variant.create!(experiment: @experiment, name: "Control", template_path: "marquee_pages/test_page", is_control: true, weight: 1)
      @variant_b = Marquee::Variant.create!(experiment: @experiment, name: "Variant B", template_path: "marquee_pages/test_page_v2", weight: 1)
    end

    test "results returns variant stats with assignment and conversion counts" do
      # 3 visitors assigned to control, 1 converts
      3.times do |i|
        Marquee::Assignment.create!(experiment: @experiment, variant: @control, visitor_token: "ctrl-#{i}", assigned_at: Time.current)
      end
      Marquee::Lead.create!(email: "ctrl@example.com", source_page: @page, visitor_token: "ctrl-0", converted_experiment_id: @experiment.id, converted_variant_id: @control.id)

      # 2 visitors assigned to variant B, 1 converts
      2.times do |i|
        Marquee::Assignment.create!(experiment: @experiment, variant: @variant_b, visitor_token: "var-#{i}", assigned_at: Time.current)
      end
      Marquee::Lead.create!(email: "var@example.com", source_page: @page, visitor_token: "var-0", converted_experiment_id: @experiment.id, converted_variant_id: @variant_b.id)

      results = @experiment.results

      control_result = results.find { |r| r[:variant_id] == @control.id }
      assert_equal 3, control_result[:assignments]
      assert_equal 1, control_result[:conversions]
      assert_in_delta 33.33, control_result[:conversion_rate], 0.01

      variant_b_result = results.find { |r| r[:variant_id] == @variant_b.id }
      assert_equal 2, variant_b_result[:assignments]
      assert_equal 1, variant_b_result[:conversions]
      assert_in_delta 50.0, variant_b_result[:conversion_rate], 0.01
    end

    test "results returns zero conversion rate when no assignments" do
      results = @experiment.results
      control_result = results.find { |r| r[:variant_id] == @control.id }

      assert_equal 0, control_result[:assignments]
      assert_equal 0, control_result[:conversions]
      assert_equal 0.0, control_result[:conversion_rate]
    end
  end
end
