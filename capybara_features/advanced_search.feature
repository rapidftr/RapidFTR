Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  Background:
    Given I am logged in
    And the following children exist in the system:
      | name   | created_by | created_at | last_updated_by | last_updated_at | 
      | Bob    | aidWorker  | 01-01-2010 | aidWorker       | 05-01-2010      | 
      | Jack   | volunteer  | 10-10-2010 | aidWorker       | 10-10-2011      |

  @javascript
  Scenario: Searching for children by the child name field
    Given I am on child advanced search page

    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I fill in "Bob OR Jack" for "criteria_list[0][value]"
    And  I press "Search"

    Then I should see "Jack" in the search results
    And  I should see "Bob" in the search results

  @javascript
  Scenario: Filtering search results by the user who created the child record
    Given I am on child advanced search page

    When I check "created_by"
    And I fill in "aidWorker" for "created_by_value"
    And I press "Search"

    Then I should see "Bob" in the search results
    And  I should not see "Jack" in the search results

  @javascript
  Scenario: Filtering search results by the users who created the child record (ORed conditions)
    Given I am on child advanced search page

    When I check "created_by"
    And I fill in "aidWorker OR volunteer" for "created_by_value"
    And I press "Search"

    Then I should see "Bob" in the search results
    And  I should see "Jack" in the search results

  @javascript
  Scenario: Filtering search results by the users who created the child record (ANDed conditions)
    Given I am on child advanced search page

    When I check "created_by"
    And I fill in "aidWorker AND volunteer" for "created_by_value"
    And I press "Search"

    Then I should see "Bob" in the search results
    And  I should see "Jack" in the search results

 @javascript
  Scenario: Filtering search results by the user who last updated the child record
    Given I am on child advanced search page

    When I check "updated_by"
    And I fill in "aidWorker" for "updated_by_value"
    And I press "Search"

    Then I should see "Bob" in the search results
    And  I should see "Jack" in the search results


  @javascript
  Scenario: Filtering search results by creation date (records created after some date)
    Given I am on child advanced search page

    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I fill in "Bob OR Jack" for "criteria_list[0][value]"
    And  I check "created_at"
    And  I fill in "15-01-2010" for "created_at_start_value"
    And  I press "Search"

    Then I should see "Jack" in the search results
    And  I should not see "Bob" in the search results

  @javascript
  Scenario: Filtering search results by last updated date (records updated before some date)
    Given I am on child advanced search page

    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I fill in "Bob OR Jack" for "criteria_list[0][value]"
    And  I check "last_updated_at"
    And  I fill in "15-01-2010" for "last_updated_at_end_value"
    And  I press "Search"

    Then I should see "Bob" in the search results
    And  I should not see "Jack" in the search results

  @javascript
  Scenario: Filtering search results using all advanced filters
    Given I am on child advanced search page

    When I check "created_by"
    And  I fill in "volunteer" for "created_by_value"
    And  I check "created_at"
    And  I fill in "01-10-2010" for "created_at_start_value"
    And  I fill in "30-10-2010" for "created_at_end_value"
    And  I check "updated_by"
    And  I fill in "aidWorker" for "updated_by_value"
    And  I check "last_updated_at"
    And  I fill in "01-10-2011" for "last_updated_at_start_value"
    And  I fill in "30-10-2011" for "last_updated_at_end_value"
    And  I press "Search"

    Then I should see "Jack" in the search results
    And  I should not see "Bob" in the search results