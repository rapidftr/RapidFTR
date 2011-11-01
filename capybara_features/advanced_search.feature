Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  Background:
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name   | created_by | created_at |
      | Bob    | aidWorker  | 01-01-2010 |
      | Jack   | volunteer  | 10-10-2010 |

  @javascript
  Scenario: Filtering search results by the user who created the child record
    Given I check "created_by"
    And I fill in "aidWorker" for "created_by_value"
    
    When I press "Search"

    Then I should see "Bob" in the search results

  @javascript
  Scenario: Filtering search results by creation date (records created after some date)
    Given I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Bob OR Jack" for "criteria_list[0][value]"
    And I press "Search"

    When I check "date_created"
    And I fill in "15-01-2010" for "date_created_value"
    And I press "Search"

    Then I should see "Jack" in the search results

  @javascript
  Scenario: Searching for children by the child name field
    Given I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Bob OR Jack" for "criteria_list[0][value]"
    
    When I press "Search"

    Then I should see "Jack" in the search results
    And I should see "Bob" in the search results
