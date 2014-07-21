# This file is copied to spec/ when you run 'rails generate rspec:install'

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear!('rails')
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'csv'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}

# This clears couchdb between tests.
FactoryGirl.find_definitions
Mime::Type.register 'application/zip', :mock


#This work if we keep in the suffix the same as the RAILS_ENV.
TEST_DATABASES = COUCHDB_SERVER.databases.select {|db| db =~ /#{ENV["RAILS_ENV"]}$/}


module VerifyAndResetHelpers
  def verify(object)
    RSpec::Mocks.space.proxy_for(object).verify
  end

  def reset(object)
    RSpec::Mocks.space.proxy_for(object).reset
  end
end

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods
  config.include UploadableFiles
  config.include ChildFinder
  config.include FakeLogin, :type => :controller
  config.include VerifyAndResetHelpers
  config.include CouchdbClientHelper

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:all) do
    reset_couchdb!
  end

  #Delete db if needed.
  config.after(:all) do
      reset_couchdb!
  end

  config.before(:each) { I18n.locale = I18n.default_locale = :en }

end

def stub_env(new_env, &block)
  original_env = Rails.env
  Rails.instance_variable_set("@_env", ActiveSupport::StringInquirer.new(new_env))
  block.call
ensure
  Rails.instance_variable_set("@_env", ActiveSupport::StringInquirer.new(original_env))
end
