ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"

# Load schema directly — avoids engine migration path conflicts.
ActiveRecord::Schema.verbose = false
load File.expand_path("dummy/db/schema.rb", __dir__)

require "rails/test_help"

class ActiveSupport::TestCase
  self.use_transactional_tests = true
end
