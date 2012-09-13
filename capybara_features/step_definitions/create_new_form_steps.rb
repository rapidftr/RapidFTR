When /^I fill the following options into "([^"]*)":$/ do |label, string|
  fill_in(label, :with => string)
end

