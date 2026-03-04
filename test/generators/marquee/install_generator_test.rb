require "test_helper"
require "rails/generators/test_case"
require "generators/marquee/install/install_generator"

class Marquee::InstallGeneratorTest < Rails::Generators::TestCase
  tests Marquee::InstallGenerator
  destination File.expand_path("../../tmp", __dir__)

  setup do
    prepare_destination
  end

  test "creates initializer" do
    run_generator
    assert_file "config/initializers/marquee.rb" do |content|
      assert_match "Marquee.configure", content
      assert_match "config.site_name", content
    end
  end

  test "shows post-install message" do
    output = run_generator
    assert_match "Marquee installed", output
  end
end
