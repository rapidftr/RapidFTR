When /^I fill in the basic details of a child$/ do
  'When I fill in "Jorge Just" for "name"'
  'And I fill in "27" for "age"'
  'And I choose "Male"'
#  And I fill in "London" for "Origin"
#  And I fill in "Haiti" for "LastKnownLocation"
#  And I select "1-2 weeks ago" from "DateOfSeparation"
end

Then /^I should see the photo of the child$/ do
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty  
end