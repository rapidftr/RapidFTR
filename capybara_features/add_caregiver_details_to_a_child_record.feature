Feature: Capture caregiver details

  Scenario: Adding caregiver details to an existing child record
    Given an user "field_worker" with "Register Child" permission
    And I am logged in as "field_worker"
    And I am on the new child page

    When I fill in the basic details of a child
    And I fill in "Mother Teresa" for "Caregiver's Name"
    And I fill in "Saint" for "If other, please provide details."
    And I fill in "Unknown" for "Relationship To Child"
    And I select "Yes" from "Does the caregiver know the family of the child?"

    When I press "Save"

    Then I should see "Mother Teresa"
    And I should see "Saint"
    And I should see "Unknown"
    And I should not see "Is child a refugee?:      No"
    And I should see "Yes"
