Feature: As a user, when I login with my credentials, my username should be used to create a unique child id

  Scenario: The unique Id of child should use the logged-in user's username

    Given I am logged in as a user with "Register Child" permission
    When I am on the new child page
    When I fill in the basic details of a child
    And I press "Save"
    Then I should see "Child record successfully created."
