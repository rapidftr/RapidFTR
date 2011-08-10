# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'spec/autorun'
require 'spec/rails'
require 'spec/support/matchers/attachment_response'
require 'pp'

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

def uploadable_photo_jorge
  uploadable_photo "features/resources/jorge.jpg"
end


def uploadable_photo_gif
  uploadable_photo "features/resources/small.gif"
end

def uploadable_photo_bmp
  uploadable_photo "features/resources/small.bmp"
end

def uploadable_photo_jorge_300x300
  uploadable_photo "features/resources/jorge-300x300.jpg"
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
  thumbnail = MiniMagick::Image.from_file(path)
  thumbnail.resize "60x60"
  thumbnail.instance_eval "def content_type; 'image/#{File.extname(path).gsub(/^\./, '').downcase}'; end"

  def thumbnail.read
    self.to_blob
  end

  thumbnail
end

def to_image(blob)
  MiniMagick::Image.from_blob(blob)
end

def uploadable_audio(audio_path = "features/resources/sample.amr")

  audio = File.new(audio_path)

  def audio.content_type
    if /amr$/.match self.path 
      "audio/amr"
    elsif /wav$/.match self.path 
      "audio/wav"
    elsif /ogg$/.match self.path 
      "audio/ogg"
    else
      "audio/mpeg"
    end
  end
  def audio.mime_type
    Mime::Type.lookup self.content_type
  end

  def audio.size
    File.size self.path
  end

  def audio.original_path
    self.path
  end

  def audio.data
    File.read self.path
  end

  audio
end

def uploadable_audio_amr
  uploadable_audio "features/resources/sample.amr"
end

def uploadable_audio_wav
  uploadable_audio "features/resources/sample.wav"
end

def uploadable_audio_mp3
  uploadable_audio "features/resources/sample.mp3"
end

def uploadable_audio_ogg
  uploadable_audio "features/resources/sample.ogg"
end

def uploadable_jpg_photo_without_file_extension
  uploadable_photo("features/resources/jorge_jpg").tap do |photo|
    def photo.content_type
      "image/jpg"
    end
  end
end


def find_child_by_name child_name
  child = Summary.by_name(:key => child_name)
  raise "no child named '#{child_name}'" if child.nil?
  child.first
end


CouchRestRails::Tests.setup

Spec::Runner.configure do |config|
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end
