
Feature:As a user ,when i log-in with my credentials,my username should be used to create a unique child id
  @wip
Scenario: The unique Id of child should use the logged-in user's username
   Given I am logged in as "mary"
   When I create a new child
   Then I should see "Child record successfully created."
   And the childs unique id should start "mary"
