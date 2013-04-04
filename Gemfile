source "http://rubygems.org"

gem 'couchrest',      '0.34'
gem 'dictionary',     '1.0.0'
gem 'fastercsv',      '1.5.3'
gem 'json',           '1.4.6'
gem 'json_pure',      '1.4.6'
gem 'mime-types',     '1.16'
gem 'mini_magick',    '1.3.2'
gem 'pdf-reader',     '0.8.6'
gem 'prawn',          '0.8.4'
gem 'rails',          '3.0.19'
gem 'rest-client',    '1.3.0'
gem 'subexec',        '0.0.4'
gem 'uuidtools',      '2.1.1'
gem 'validatable',    '1.6.7'
gem 'sunspot',				'1.3.3'
gem 'tzinfo'
gem 'rake',           '0.8.7'
gem 'dynamic_form'
gem 'jquery-rails'
gem 'cancan'
gem 'capistrano'
gem 'will_paginate'
gem "i18n-js"
gem 'therubyracer' , :platforms => :ruby
gem 'win32-open3' , :platforms => [:mswin, :mingw]
gem 'os'
gem 'libv8', '~> 3.11.8', :platform => :ruby
gem 'thin', :platform => :ruby, :require => false

# NOTE: zipruby gem needs to be installed in Windows using a special gem install directive, which is unsupported by bundler
# NOTE: Sunspot 1.3.3 has bug in Linux, But 1.3.1 has problem in Windows
if RUBY_PLATFORM =~ /(win32|w32)/
  gem 'zipruby', '0.3.6', :path => "vendor/windows/gems/zipruby-0.3.6-x86-mswin32"
  gem 'sunspot_solr',   '1.3.3'
else
  gem 'zipruby', '~> 0.3.6'
  gem 'sunspot_solr', '1.3.1'
end
# NOTE: Having If conditions in the Gemfile is not generally recommended
# Because using the above code, if you run bundle install in Linux, it will generate a different Gemfile.lock
# And then if you run bundle install in Windows, it will cause problems, since the Gemfile.lock is a mismatch
# There are two ways to do this:
#   1) Different Gemfiles for Linux and Windows, which will end up generating different lock files
#   2) Delete Gemfile.lock before doing bundle install in Windows
# Both are equally troublesome, and both will end up with different versions of gems installed by bundler for Windows and Linux
# Right now we're choosing to delete Gemfile.lock in Windows before doing bundle install

gem 'rufus-scheduler', :require => false
gem 'daemons', :require => false

group :development, :assets do
  gem 'rubyzip'
  gem 'sass'
end

group :assets do
  gem 'compass-rails'
  gem 'uglifier'
  gem 'jammit'
end

group :development do
  gem 'guard-rspec'
  gem 'rb-readline'
  gem 'rb-fsevent', :require => false
  gem 'terminal-notifier-guard'
end

group :development, :test, :cucumber do
  gem 'rspec',            '2.11.0'
  gem 'rspec-rails',      '2.11.0'
  gem 'rspec-instafail'

  gem 'capybara',         '1.0.1'
  gem 'factory_girl', '~> 2.6'
  gem 'jasmine'
  gem 'pry'
  gem 'mocha'
  gem 'test_declarative'
end

group :test, :cucumber do
  gem 'cucumber',         '1.2.1'
  gem 'cucumber-rails',   '0.3.2'
  gem 'selenium-webdriver', '~> 2.30'
  gem 'hpricot',          '0.8.2'
  gem 'launchy',          '0.4.0'
  gem 'rcov', :platforms => :ruby_18
end
