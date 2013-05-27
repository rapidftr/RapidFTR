source 'https://rubygems.org'
ruby '1.9.3'

gem 'rapidftr_addon', :git => 'git://github.com/farismosman/rapidftr-addon.git', :branch => 'master'
gem 'rapidftr_addon_cpims', :git => 'git://github.com/farismosman/rapidftr-addon-cpims.git', :branch => 'master'

gem 'couchrest',      '0.34'
gem 'mime-types',     '1.16'
gem 'mini_magick',    '1.3.2'
gem 'pdf-reader',     '0.8.6'
gem 'prawn',          '0.8.4'
gem 'rails',          '3.0.20'
gem 'rest-client',    '1.3.0'
gem 'uuidtools',      '2.1.1'
gem 'validatable',    '1.6.7'
gem 'dynamic_form',   '~> 1.1.4'
gem 'sunspot',        '1.3.3'
gem 'rake',           '0.8.7'
gem 'jquery-rails',   '~> 2.2.1'
gem 'cancan',         '~> 1.6.9'
gem 'capistrano',     '~> 2.14.2'
gem 'highline',       '1.6.16'
gem 'will_paginate',  '~> 3.0.4'
gem 'i18n-js',        '~> 2.1.2'
gem 'therubyracer',   '~> 0.11.4', :platforms => :ruby, :require => 'v8'
gem 'os',             '~> 0.9.6'
gem 'thin',           '~> 1.5.1',  :platform => :ruby, :require => false
gem 'encrypted-cookie-store', '~> 1.0'

# NOTE: zipruby gem needs to be installed in Windows using a special gem install directive, which is unsupported by bundler
# NOTE: Sunspot 1.3.3 has bug in Linux, But 1.3.1 has problem in Windows
if RUBY_PLATFORM =~ /(win32|w32)/
  gem 'zipruby',      '0.3.6', :path => 'vendor/windows/gems/zipruby-0.3.6-x86-mswin32'
  gem 'sunspot_solr', '1.3.3'
else
  gem 'zipruby',      '~> 0.3.6'
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

gem 'rufus-scheduler', '~> 2.0.18', :require => false
gem 'daemons',         '~> 1.1.9',  :require => false

group :development do
  gem 'active_reload'
end

group :development, :assets do
  gem 'rubyzip',       '~> 0.9.9'
  gem 'sass',          '~> 3.2.7'
end

group :assets do
  gem 'compass-rails', '~> 1.0.3'
  gem 'uglifier',      '~> 2.0.1'
  gem 'jammit',        '~> 0.6.6'
end

group :test, :cucumber do
  gem 'factory_girl',     '~> 2.6'

  gem 'rspec',            '~> 2.11.0'
  gem 'rspec-rails',      '~> 2.11.0'
  gem 'rspec-instafail',  '~> 0.2.4'
  gem 'jasmine',          '~> 1.3.2'

  gem 'capybara',         '~> 2.1.0'
  gem 'cucumber',           '~> 1.2.2'
  gem 'cucumber-rails',     '~> 1.3.1', :require => false
  gem 'selenium-webdriver', '~> 2.30'
  gem 'hpricot',            '~> 0.8.6'
  gem "json_spec",          '~> 1.1.1'
end
