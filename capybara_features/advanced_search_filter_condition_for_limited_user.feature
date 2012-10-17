Feature: So that I am not able to search user created by other user
  As a limited user
  I want to disable search by 'created by' condition for advanced search

  Background:
    Given a user "mary" with password "123" and "limited" permission
    And a user "ted" with password "123" and "unlimited" permission
    And the following children exist in the system:
      | name   | created_by |
      | Willis | mary       |
      | Willas | mary       |
      | Willus | ted        |

  Scenario: Should not show "Created by" condition
    Given I am logged in as "mary"

    When I am on child advanced search page

    Then I should not see "Created By:"

  @javascript
  Scenario: Should filter children created by other user in search result
    Given I am logged in as "mary"
    And I am on child advanced search page

    When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Will" for "criteria_list[0][value]"
    And I press "Search"

    Then I should see "Willis" in the search results
    And I should see "Willas" in the search results
    And I should not see "Willus" in the search results


