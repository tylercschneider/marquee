require "test_helper"

module Marquee
  class FunnelResultsTest < ActiveSupport::TestCase
    setup do
      @landing = Page.create!(
        title: "Landing", slug: "results-landing", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @pricing = Page.create!(
        title: "Pricing", slug: "results-pricing", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @checkout = Page.create!(
        title: "Checkout", slug: "results-checkout", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )

      @funnel = Funnel.create!(name: "Signup", slug: "results-signup")
      @step1 = FunnelStep.create!(funnel: @funnel, page: @landing, position: 1, label: "Landing")
      @step2 = FunnelStep.create!(funnel: @funnel, page: @pricing, position: 2, label: "Pricing")
      @step3 = FunnelStep.create!(funnel: @funnel, page: @checkout, position: 3, label: "Checkout")
    end

    test "returns per-step visitor counts and drop-off rates" do
      # 100 visitors hit landing
      100.times { |i| FunnelProgress.create!(funnel_step: @step1, visitor_token: "v#{i}") }
      # 60 reach pricing
      60.times { |i| FunnelProgress.create!(funnel_step: @step2, visitor_token: "v#{i}") }
      # 30 reach checkout
      30.times { |i| FunnelProgress.create!(funnel_step: @step3, visitor_token: "v#{i}") }

      results = @funnel.results

      assert_equal 3, results.size

      assert_equal({ position: 1, label: "Landing", page_slug: "results-landing", visitors: 100, drop_off_rate: 0.0 }, results[0])
      assert_equal({ position: 2, label: "Pricing", page_slug: "results-pricing", visitors: 60, drop_off_rate: 40.0 }, results[1])
      assert_equal({ position: 3, label: "Checkout", page_slug: "results-checkout", visitors: 30, drop_off_rate: 50.0 }, results[2])
    end

    test "returns zero visitors and zero drop-off for empty funnel" do
      results = @funnel.results

      assert_equal 3, results.size
      results.each do |step_result|
        assert_equal 0, step_result[:visitors]
        assert_equal 0.0, step_result[:drop_off_rate]
      end
    end

    test "step 1 always has 0 drop-off rate" do
      10.times { |i| FunnelProgress.create!(funnel_step: @step1, visitor_token: "v#{i}") }

      results = @funnel.results
      assert_equal 0.0, results[0][:drop_off_rate]
    end

    test "results are ordered by position" do
      results = @funnel.results
      positions = results.map { |r| r[:position] }
      assert_equal [ 1, 2, 3 ], positions
    end
  end
end
