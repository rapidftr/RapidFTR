Feature:
  So that we can keep track of children that are found in the field, a user should be able to go to a website and upload
  basic information about the lost child.

Scenario:
  Given I am on new child page
  When I fill in "Jorge Just" for "name"
  And I fill in "27" for "Age"
#  And I choose "Male"
#  And I fill in "London" for "Origin"
#  And I fill in "Haiti" for "LastKnownLocation"
#  And I select "1-2 weeks ago" from "DateOfSeparation"
  And I press "Create"
  Then I should see "Child record successfully created."
  And I should see "Jorge Just"
  And I should see "27"
#  And I should see "Male"
#  And I should see "London" within "Origin"
#  And I should see "Haiti" within "LastKnownLocation"
#  And I should see "1-2 weeks ago" within "DateOfSeparation"
