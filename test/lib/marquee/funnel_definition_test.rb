require "test_helper"

module Marquee
  class FunnelDefinitionTest < ActiveSupport::TestCase
    setup do
      FunnelDefinition.registry.clear

      @landing = Page.create!(
        title: "Landing", slug: "funnel-def-landing", status: "published",
        published_at: Time.current, template_path: "marquee_pages/landing"
      )
      @pricing = Page.create!(
        title: "Pricing", slug: "funnel-def-pricing", status: "published",
        published_at: Time.current, template_path: "marquee_pages/pricing"
      )
    end

    teardown do
      FunnelDefinition.registry.clear
    end

    test "DSL parses name and steps" do
      Marquee.define_funnel :signup_flow do
        name "Signup Flow"
        step :"funnel-def-landing", label: "Landing Page", position: 1
        step :"funnel-def-pricing", label: "Pricing", position: 2
      end

      defn = FunnelDefinition.registry[:signup_flow]
      assert_equal "signup_flow", defn.slug
      assert_equal "Signup Flow", defn.funnel_name
      assert_equal 2, defn.steps.size
      assert_equal({ page_slug: :"funnel-def-landing", label: "Landing Page", position: 1 }, defn.steps.first)
    end

    test "sync! creates funnel and steps in database" do
      Marquee.define_funnel :signup_flow do
        name "Signup Flow"
        step :"funnel-def-landing", label: "Landing Page", position: 1
        step :"funnel-def-pricing", label: "Pricing", position: 2
      end

      FunnelDefinition.sync!

      funnel = Funnel.find_by!(slug: "signup_flow")
      assert_equal "Signup Flow", funnel.name
      assert_equal 2, funnel.funnel_steps.count
      assert_equal @landing, funnel.funnel_steps.find_by(position: 1).page
      assert_equal @pricing, funnel.funnel_steps.find_by(position: 2).page
    end

    test "sync! is idempotent" do
      Marquee.define_funnel :signup_flow do
        name "Signup Flow"
        step :"funnel-def-landing", label: "Landing Page", position: 1
      end

      FunnelDefinition.sync!
      FunnelDefinition.sync!

      assert_equal 1, Funnel.where(slug: "signup_flow").count
      assert_equal 1, Funnel.find_by!(slug: "signup_flow").funnel_steps.count
    end

    test "sync! removes steps no longer in DSL" do
      Marquee.define_funnel :signup_flow do
        name "Signup Flow"
        step :"funnel-def-landing", label: "Landing Page", position: 1
        step :"funnel-def-pricing", label: "Pricing", position: 2
      end

      FunnelDefinition.sync!
      assert_equal 2, Funnel.find_by!(slug: "signup_flow").funnel_steps.count

      # Redefine without pricing step
      FunnelDefinition.registry.clear
      Marquee.define_funnel :signup_flow do
        name "Signup Flow"
        step :"funnel-def-landing", label: "Landing Page", position: 1
      end

      FunnelDefinition.sync!
      assert_equal 1, Funnel.find_by!(slug: "signup_flow").funnel_steps.count
    end

    test "sync! is called from PageDefinition.sync!" do
      PageDefinition.registry.clear

      Marquee.define_funnel :test_flow do
        name "Test Flow"
        step :"funnel-def-landing", label: "Landing", position: 1
      end

      PageDefinition.sync!

      assert Funnel.exists?(slug: "test_flow")
    ensure
      PageDefinition.registry.clear
    end
  end
end
