When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

