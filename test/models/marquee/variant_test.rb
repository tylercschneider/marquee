require "test_helper"

module Marquee
  class VariantTest < ActiveSupport::TestCase
    setup do
      @page = Marquee::Page.create!(
        title: "Test Page", slug: "variant-test", status: "published",
        published_at: Time.current, template_path: "marquee_pages/test_page"
      )
      @experiment = Marquee::Experiment.create!(name: "Test", page: @page)
    end

    test "requires a name" do
      variant = Marquee::Variant.new(experiment: @experiment, template_path: "t")
      assert_not variant.valid?
      assert_includes variant.errors[:name], "can't be blank"
    end

    test "requires a template_path" do
      variant = Marquee::Variant.new(experiment: @experiment, name: "Control")
      assert_not variant.valid?
      assert_includes variant.errors[:template_path], "can't be blank"
    end

    test "requires an experiment" do
      variant = Marquee::Variant.new(name: "Control", template_path: "t")
      assert_not variant.valid?
      assert_includes variant.errors[:experiment], "must exist"
    end

    test "defaults weight to 1" do
      variant = Marquee::Variant.new(name: "Control", experiment: @experiment, template_path: "t")
      assert_equal 1, variant.weight
    end

    test "defaults is_control to false" do
      variant = Marquee::Variant.new(name: "Control", experiment: @experiment, template_path: "t")
      assert_equal false, variant.is_control
    end

    test "belongs to experiment" do
      variant = Marquee::Variant.create!(
        experiment: @experiment, name: "Control",
        template_path: "marquee_pages/test_page", is_control: true
      )
      assert_equal @experiment, variant.experiment
    end
  end
end
