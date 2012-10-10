require 'test/unit'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}

# This clears couchdb between tests.
CouchRestRails::Tests.setup

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
