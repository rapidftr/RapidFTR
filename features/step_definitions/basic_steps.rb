When /^I fill in the basic details of a child$/ do
  'When I fill in "Jorge Just" for "name"'
  'And I fill in "27" for "age"'
  'And I choose "Male"'
#  And I fill in "London" for "Origin"
#  And I fill in "Haiti" for "LastKnownLocation"
#  And I select "1-2 weeks ago" from "DateOfSeparation"
end

When /^I attach a photo$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the photo of the child$/ do
  pending # express the regexp above with the code you wish you had
end
