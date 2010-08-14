# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'spec/autorun'
require 'spec/rails'
require 'spec/support/matchers/attachment_response'

# Uncomment the next line to use webrat's matchers
require 'webrat/integrations/rspec-rails'
require 'RMagick'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each {|f| require f}

def uploadable_photo( photo_path = "features/resources/jorge.jpg" )
  photo = File.new(photo_path)

  def photo.content_type
    "image/#{File.extname( self.path ).gsub( /^\./, '' ).downcase}"
  end

  def photo.size
    File.size self.path
  end

  def photo.original_path
    self.path
  end

  def photo.data
    File.read self.path
  end

  photo
end

def uploadable_photo_jeff
  uploadable_photo "features/resources/jeff.png"
end

def no_photo_clip
  uploadable_photo "public/images/no_photo_clip.jpg"
end

def uploadable_text_file
  file = File.new("features/resources/textfile.txt")

  def file.content_type
    "text/txt"
  end

  def file.original_path
    self.path
  end

  file
end

def to_thumbnail(size, path)
  thumbnail = Magick::Image.read(path).first.resize_to_fill(size)
  thumbnail.instance_eval "def content_type; 'image/#{File.extname(path).gsub(/^\./, '').downcase}'; end"

  def thumbnail.read
    self.to_blob
  end

  thumbnail
end

def find_child_by_name child_name
  child = Summary.by_name(:key => child_name)
  raise "no child named '#{child_name}'" if child.nil?
  child.first
end


CouchRestRails::Tests.setup
Spec::Runner.configure do |config|

  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
#  config.use_transactional_fixtures = true
#  config.use_instantiated_fixtures  = false
#  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end
