Feature:
  So that we can go back to search results

Background:
  Given I am logged in
  And the following children exist in the system:
    | name   |
    | Patrick |
    | Patrick 2 |

  Scenario: Viewing a child record after selecting a search result
    Given I am on the child search page
    And I fill in "Patrick" for "Name"
    And I press "Search"
    And I should see "Patrick" in the search results
    And I follow "Patrick"

    When I follow "Back"
    Then I should be in the child search results page
    Then I should see "Patrick"
