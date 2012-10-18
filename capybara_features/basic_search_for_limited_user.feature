Feature: So that I can find a child that has been entered in to RapidFTR
  As a limited user of the website
  I want to enter a search query in to a search box and see all children registered by me.

  Scenario: Limited user should not see children registered by other users in search results
    Given a user "Tim" with "Access all data" permission
    And a user "John" with "limited" permission
    And the following children exist in the system:
      | name   | created_by |
      | Andrew | Tim    |
      | Peter  | John  |
    When I am logged in as "John"
    And I am on the child search page
    When I fill in "Andrew" for "Name or Unique ID"
    And I press "Search"
    Then I should see "No results found"
    When I fill in "Peter" for "Name or Unique ID"
    And I press "Search"
    Then I should not see "No results found"

