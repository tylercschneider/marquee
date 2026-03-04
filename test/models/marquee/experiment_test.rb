require "test_helper"

module Marquee
  class ExperimentTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test Page", slug: "experiment-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
    end

    test "requires a name" do
      experiment = Marquee::Experiment.new(page: @page)
      assert_not experiment.valid?
      assert_includes experiment.errors[:name], "can't be blank"
    end

    test "requires a page" do
      experiment = Marquee::Experiment.new(name: "Test")
      assert_not experiment.valid?
      assert_includes experiment.errors[:page], "must exist"
    end

    test "defaults status to draft" do
      experiment = Marquee::Experiment.new(name: "Test", page: @page)
      assert_equal "draft", experiment.status
    end

    test "defaults metric to lead_capture" do
      experiment = Marquee::Experiment.new(name: "Test", page: @page)
      assert_equal "lead_capture", experiment.metric
    end

    test "validates status inclusion" do
      experiment = Marquee::Experiment.new(name: "Test", page: @page, status: "invalid")
      assert_not experiment.valid?
      assert_includes experiment.errors[:status], "is not included in the list"
    end

    test "running scope returns only running experiments" do
      draft = Marquee::Experiment.create!(name: "Draft", page: @page)
      running = Marquee::Experiment.create!(name: "Running", page: @page, status: "running", started_at: Time.current)

      assert_includes Marquee::Experiment.running, running
      assert_not_includes Marquee::Experiment.running, draft
    end

    test "belongs to page" do
      experiment = Marquee::Experiment.create!(name: "Test", page: @page)
      assert_equal @page, experiment.page
    end

    test "has many variants" do
      experiment = Marquee::Experiment.create!(name: "Test", page: @page)
      variant = Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )
      assert_includes experiment.variants, variant
    end

    test "destroys variants when destroyed" do
      experiment = Marquee::Experiment.create!(name: "Test", page: @page)
      Marquee::Variant.create!(
        experiment: experiment, name: "Control",
        template_path: "marquee_pages/test_page"
      )
      assert_difference "Marquee::Variant.count", -1 do
        experiment.destroy!
      end
    end
  end
end
