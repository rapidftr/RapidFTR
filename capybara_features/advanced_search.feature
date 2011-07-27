Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  @javascript
  Scenario: Searching for children by the user who created the child record
    Given the following children exist in the system:
      | name   | created_by |
      | Willis | aidWorker  |
      | Will   | volunteer  |

    And I am logged in
    And I am on child advanced search page

    When I check "created_by"
    And I fill in "aidWorker" for "created_by_value"
    And I press "Search"

    And I should see "Willis" in the search results

  @javascript
  Scenario: Searching for children by the child name field
    Given the following children exist in the system:
      | name   | created_by |
      | Willis | aidWorker  |
      | Will   | volunteer  |

    And I am logged in
    And I am on child advanced search page

    When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Wil" for "criteria_list[0][value]"
    And I press "Search"

    And I should see "Willis" in the search results
    And I should see "Will" in the search results