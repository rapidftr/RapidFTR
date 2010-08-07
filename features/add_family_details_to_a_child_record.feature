Feature: Add family details

  Scenario: Storing family names
    Given I am logged in
    Given I am on the new child page
    When I fill in the basic details of a child
    And I fill in "Mary" for "Mothers name"
    And I select "Yes" from "Reunite with mother"

    When I press "Save"

    Then I should see "Mary"
    And I should see "Reunite with mother: Yes"




