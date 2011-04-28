require 'rubygems'
require 'rb-fsevent'
require 'growl'

guard 'livereload', :apply_js_live => false do
  watch(%r{^spec/coffeescripts/(.*)\.coffee})
  watch(%r{^app/coffeescripts/(.*)\.coffee})
  watch(%r{^spec/javascripts/.+\.js$})
  watch(%r{^public/javascripts/.+\.js$})
end

