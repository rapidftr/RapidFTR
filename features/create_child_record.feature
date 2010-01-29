Feature:
  So that we can keep track of children that are found in the field, a user should be able to go to a website and upload
  basic information about the lost child.

Scenario:
  Given I am on new child page
  When I fill in "Jorge" for "Firstname"
  And I fill in "Just" for "Surname"
  And I choose "Male"
  And I fill in "27" for "Age"
  And I fill in "London" for "Origin"
  And I fill in "Haiti" for "LastKnownLocation"
  And I select "1-2 weeks ago" from "DateOfSeparation"
  And I press "Submit"
  Then I am on view child page
  And I should see "Child record successfully created"
  And I should see "Jorge" within "Firstname"
  And I should see "Just" within "Surname"
  And I should see "Male"
  And I should see "27" within "Age"
  And I should see "London" within "Origin"
  And I should see "Haiti" within "LastKnownLocation"
  And I should see "1-2 weeks ago" within "DateOfSeparation"