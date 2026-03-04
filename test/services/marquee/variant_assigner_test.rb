require "test_helper"

module Marquee
  class VariantAssignerTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test", slug: "assigner-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @experiment = Marquee::Experiment.create!(name: "Test", page: @page, status: "running", started_at: Time.current)
      @control = Marquee::Variant.create!(experiment: @experiment, name: "Control", template_path: "marquee_pages/test_page", is_control: true, weight: 1)
      @variant_b = Marquee::Variant.create!(experiment: @experiment, name: "Variant B", template_path: "marquee_pages/test_page_v2", weight: 1)
    end

    test "assigns a variant and creates assignment record" do
      assigner = Marquee::VariantAssigner.new
      result = assigner.call(@experiment, "visitor-1")

      assert_includes [ @control, @variant_b ], result
      assert_equal 1, Marquee::Assignment.count
      assert_equal "visitor-1", Marquee::Assignment.first.visitor_token
    end

    test "returns same variant for same visitor (sticky)" do
      assigner = Marquee::VariantAssigner.new
      first_result = assigner.call(@experiment, "visitor-1")
      second_result = assigner.call(@experiment, "visitor-1")

      assert_equal first_result, second_result
      assert_equal 1, Marquee::Assignment.count
    end

    test "respects weights in distribution" do
      # Give variant_b 99x weight so it's almost always chosen
      @control.update!(weight: 1)
      @variant_b.update!(weight: 99)

      assigner = Marquee::VariantAssigner.new
      results = 50.times.map { |i| assigner.call(@experiment, "visitor-#{i}") }

      variant_b_count = results.count { |v| v == @variant_b }
      # With 99:1 odds, expect most to be variant_b
      assert variant_b_count > 30, "Expected most assignments to go to higher-weighted variant, got #{variant_b_count}/50"
    end

    test "different visitors can get different variants" do
      assigner = Marquee::VariantAssigner.new
      results = 20.times.map { |i| assigner.call(@experiment, "visitor-#{i}") }

      # With equal weights and 20 visitors, we should see both variants
      unique_variants = results.uniq
      assert unique_variants.size > 1, "Expected multiple variants to be assigned across 20 visitors"
    end
  end
end
