require 'rubygems'
require 'sinatra'
require 'pp'

ROOT = File.dirname(__FILE__)



def available_forms
  form_dir = File.join( settings.public, 'forms' )
  files = []
  Dir.new(form_dir).each do |entry|
   if File.file?( File.join( form_dir, entry ) )
     files << entry
   end
  end
  files
end

def base_url
  "#{request.scheme}://#{request.host}:#{request.port}#{request.script_name}"
end

def url_for_form_file( filename )
  File.join( base_url, 'forms', filename )
end

def submission_filepath( filename )
  File.join( settings.public, 'submitted', filename )
end

def submission_url( filename )
  File.join( base_url, 'submitted', filename )
end

get '/formList' do
  builder do |xml|
    xml.instruct!
    xml.forms {
      available_forms.each do |form_filename|
        xml.form( form_filename, :url => url_for_form_file(form_filename) )
      end
    }
  end
end


post '/submission' do
  params.each do |multipart_key,multipart_contents|
    original_filename = multipart_contents[:filename]
    tempfile = multipart_contents[:tempfile]
    FileUtils.copy( tempfile.path, submission_filepath( original_filename ) )
  end
  redirect base_url, 201
end
