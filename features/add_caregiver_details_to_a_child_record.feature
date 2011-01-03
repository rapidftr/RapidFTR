Feature: Capture caregiver details

  Scenario: Adding caregiver details to an existing child record
    Given I am logged in
    And I am on the new child page

    When I fill in the basic details of a child
    And I fill in "Mother Teresa" for "Caregiver's name"
    And I fill in "Saint" for "Occupation"
    And I fill in "Unknown" for "Relationship to child"
    And I choose "child_is_unaccompanied_yes"

    When I press "Save"

    Then I should see "Mother Teresa"
    And I should see "Saint"
    And I should see "Unknown"
    And I should not see "Is child a refugee?:      No"
    And I should see "Yes"
                      