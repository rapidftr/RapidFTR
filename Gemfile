source 'https://rubygems.org'
ruby '1.9.3'

gem 'rapidftr_addon', :git => 'https://github.com/rapidftr/rapidftr-addon.git', :branch => 'master'
gem 'rapidftr_addon_cpims', :git => 'https://github.com/rapidftr/rapidftr-addon-cpims.git', :branch => 'master'

gem 'couchrest_model', '~> 2.0.1'
gem 'mime-types',     '1.16'
gem 'mini_magick',    '1.3.2'
gem 'pdf-reader',     '0.8.6'
gem 'prawn',          '0.8.4'
gem 'rails',          '4.0.3'
gem 'uuidtools',      '~> 2.1.1'
gem 'validatable',    '1.6.7'
gem 'dynamic_form',   '~> 1.1.4'
gem 'sunspot',        '2.0.0'
gem 'rake',           '0.9.3'
gem 'jquery-rails'
#gem 'cancan',         '~> 1.6.9'
gem 'cancancan', '~> 1.7'
gem 'capistrano',     '~> 2.14.2'
gem 'highline',       '1.6.16'
gem 'will_paginate',  '~> 3.0.5'
gem 'i18n-js',        '~> 2.1.2'
gem 'therubyracer',   '~> 0.11.4', :platforms => :ruby, :require => 'v8'
gem 'os',             '~> 0.9.6'
gem 'thin',           '~> 1.6.1', :platforms => :ruby, :require => false
gem 'request_exception_handler'
gem 'multi_json',     '~> 1.8.2'
gem 'sunspot_solr',   '2.0.0'
gem "zipruby-compat", :require => 'zipruby', :git => "https://github.com/jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"

gem 'rufus-scheduler', '~> 2.0.18', :require => false
gem 'daemons',         '~> 1.1.9',  :require => false

group :development, :assets, :cucumber do
  gem 'sass-rails',    '~> 4.0.1'
  gem 'compass-rails', '~> 1.1.3'
  gem 'coffee-rails',  '~> 4.0.1'
  gem 'uglifier',      '~> 2.0.1'
  gem 'pry'
  gem 'pry-debugger'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :test, :cucumber do
  gem 'factory_girl',     '~> 2.6'

  gem 'rspec',            '~> 2.14.1'
  gem 'rspec-rails',      '~> 2.14.1'
  gem 'rspec-instafail',  '~> 0.2.4'
  gem 'jasmine',          '~> 1.3.2'

  gem 'capybara',         '~> 2.2.1'
  gem 'cucumber',           '~> 1.3.11'
  gem 'cucumber-rails',     '~> 1.4.0', :require => false
  gem 'selenium-webdriver', '~> 2.40.0'
  gem 'hpricot',            '~> 0.8.6'
  gem "json_spec",          '~> 1.1.1'
end
