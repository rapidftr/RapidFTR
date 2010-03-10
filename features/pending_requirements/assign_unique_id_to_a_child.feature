Feature:As a user ,when I login with my credentials,my username should be used to create a unique child id
 @wip
  Scenario: The unique Id of child should use the logged-in user's username
    Given I am logged in as "mary"
    When I fill in the basic details of a child
    And I attach the file "features/resources/jorge.jpg" to "photo"
    And I press "Create"
    Then I should see "Child record successfully created."
    And the childs unique id should start with "mary"
