require 'couch_rest_rails'

%w(couchrest json validatable).each do |g|
  begin
    require g
  rescue LoadError
    puts "Could not load required gem '#{g}'" 
    exit
  end
end