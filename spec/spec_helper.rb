# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'spec/autorun'
require 'spec/rails'

# Uncomment the next line to use webrat's matchers
require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each {|f| require f}

Spec::Rails::Example::ControllerExampleGroup.module_eval do
  include FakeLogin
end

def uploadable_photo( photo_path = "features/resources/jorge.jpg" )
  photo = File.new(photo_path)

  def photo.content_type
    "image/jpg"
  end
  
  def photo.size
    File.size "features/resources/jorge.jpg"
  end
  
  def photo.original_path
    self.path
  end
  photo
end

def uploadable_photo_jeff
  photo = File.new("features/resources/jeff.png")

  def photo.content_type
    "image/png"
  end

  def photo.size
    File.size "features/resources/jeff.png"
  end  

  def photo.original_path
    "features/resources/jeff.png"
  end
  photo
end

def uploadable_text_file
  photo = File.new("features/resources/textfile.txt")

  def photo.content_type
    "text/txt"
  end

  def photo.original_path
    "features/resources/textfile.txt"
  end
  photo
end


CouchRestRails::Tests.setup

Spec::Runner.configure do |config|
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end
