Feature: Add family details

  Scenario: Storing family names
    
    Given I am on the new child page
    And I attach the file "features/resources/jorge.jpg" to "photo"
    And I fill in "Haiti" for "Last known location"
    And I fill in "Mary" for "Mothers name"
    And I select "Yes" from "Reunite with mother"

    When I press "Create"

    Then I should see "Mary"
    And I should see "Reunite with mother: Yes"




