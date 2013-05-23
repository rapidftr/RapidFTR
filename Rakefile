# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'rake/dsl_definition'
require 'rake'
require 'rspec/core/rake_task'

include Rake::DSL
RapidFTR::Application.load_tasks


RSpec::Core::RakeTask.new('spec')

task(:default).clear

desc 'Default: run specs.'
task :default => 'spec'

# desc 'Default: run specs.'
# task :test => :spec