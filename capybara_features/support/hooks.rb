
# Before each scenario...
Before do
#  CouchRestRails::Tests.setup
end

# After each scenario...
After do |scenario|
  if scenario.failed?
    #$stdout.puts page.body
  end
#  CouchRestRails::Tests.teardown
end
