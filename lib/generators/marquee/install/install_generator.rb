module Marquee
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Install Marquee: create initializer and copy migrations"

    def copy_initializer
      template "initializer.rb", "config/initializers/marquee.rb"
    end

    def copy_migrations
      rake "marquee:install:migrations"
    end

    def display_post_install
      say ""
      say "Marquee installed! Next steps:", :green
      say "  1. Run: rails db:migrate"
      say "  2. Edit: config/initializers/marquee.rb"
      say "  3. Mount in routes: mount Marquee::Engine => '/'"
      say ""
    end
  end
end
