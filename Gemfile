source 'https://rubygems.org'

gem 'rapidftr_addon', :git => 'https://github.com/rapidftr/rapidftr-addon.git', :branch => 'master'
gem 'rapidftr_addon_cpims', :git => 'https://github.com/rapidftr/rapidftr-addon-cpims.git', :branch => 'master'

gem 'rails',           '4.0.3'
gem 'couchrest_model', '~> 2.0.1'
gem 'mime-types',      '~> 1.16'
gem 'mini_magick',     '~> 3.7.0'
gem 'prawn',           '~> 0.8.4'
gem 'uuidtools',       '~> 2.1.1'
gem 'validatable',     '~> 1.6.7'
gem 'dynamic_form',    '~> 1.1.4'
gem 'sunspot',         '~> 2.1.0'
gem 'sunspot_rails',   '~> 2.1.0'
gem 'sunspot_solr',    '~> 2.1.0'
gem 'rake',            '~> 0.9.3'
gem 'cancancan',       '~> 1.7'
gem 'highline',        '~> 1.6.16'
gem 'will_paginate',   '~> 3.0.5'
gem 'os',              '~> 0.9.6'
gem 'zipruby-compat', :require => 'zipruby', :git => "https://github.com/jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"

gem 'rufus-scheduler',  '~> 2.0.18', :require => false
gem 'daemons',          '~> 1.1.9',  :require => false
gem 'progress_bar',     '~> 1.0.2',  :require => false

gem 'sass-rails',    '~> 4.0.1'
gem 'uglifier',      '~> 2.0.1'
gem 'execjs',        '~> 2.2.0'
gem 'i18n-js',       '~> 2.1.2'

group :development do
  gem 'pry-rails',         '~> 0.3.2', platforms: :ruby
  gem 'better_errors',     '~> 1.1.0'
  gem 'binding_of_caller', '~> 0.7.2'
end

group :test, :cucumber do
  gem 'factory_girl',       '~> 4.4.0'

  gem 'rspec',              '~> 3.0'
  gem 'rspec-rails',        '~> 3.0'
  gem 'rspec-activemodel-mocks', '~> 1.0.1'

  gem 'capybara',           '~> 2.3'
  gem 'cucumber',           '~> 1.3.11'
  gem 'cucumber-rails',     '~> 1.4.0', :require => false
  gem 'selenium-webdriver', '~> 2.42.0'
  gem 'hpricot',            '~> 0.8.6'
  gem 'json_spec',          '~> 1.1.2'
  gem 'pdf-inspector',      '~> 1.1.0'
  gem 'coveralls', require: false
end

group :development, :test, :cucumber do
  gem 'quiet_assets',       '~> 1.0.3'
end

group :development, :test do
  gem 'cane',               '~> 2.6.2'
  gem 'rubocop',            '~> 0.24.1'
end
