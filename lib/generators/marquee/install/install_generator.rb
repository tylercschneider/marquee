module Marquee
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Install Marquee: create initializer and copy migrations"

    def copy_initializer
      template "initializer.rb", "config/initializers/marquee.rb"
    end
  end
end
