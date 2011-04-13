guard 'coffeescript', :output => 'public/javascripts/compiled' do
  watch(%r{^app/coffeescripts/(.*)\.coffee})
end

guard 'coffeescript', :output => 'spec/javascripts' do
  watch(%r{^spec/coffeescripts/(.*)\.coffee})
end

guard 'livereload', :apply_js_live => false do
  watch(%r{^spec/javascripts/.+\.js$})
  watch(%r{^public/javascripts/compiled/.+\.js$})
end