Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

#  Search by Advanced Criteria

  @javascript
  Scenario: Validation of search criteria field name
    Given I am logged in
    When I am on child advanced search page
    And I press "Search"
    Then I should see "Please select a valid field name"

  @javascript
  Scenario: Validation of search criteria field value
    Given I am logged in
    When I am on child advanced search page
    And I click text "Select A Criteria"
    And I click text "Name"
    And I press "Search"
    Then I should see "Please enter a valid field value"

  @javascript
  Scenario: Searching by 'Name'
    Given the following children exist in the system:
      | name   |
      | Willis |
      | Will   |
    And I am logged in
    And I am on child advanced search page
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Will" for "criteria_list[0][value]"
    And I press "Search"
   Then I should see "Will" in the search results
    And I should see "Willis" in the search results

#  Story #622 : Advanced Search - Search by User & Record Details
#  As a user
#  I want to be able to search records by system criteria such as the date the record was created and which user created it.

#  CREATED BY

  @javascript
  Scenario: Validation of 'Created by'
    Given I am logged in
    When I am on child advanced search page
    And I check "created_by"
    And I press "Search"
    Then I should see "Please enter a valid 'Created by' value"

  @javascript
  Scenario: Searching by 'Created By'
    Given the following children exist in the system:
      | name   | created_by |
      | Andrew | aidWorker  |
      | Peter  | volunteer  |
    And I am logged in
    And I am on child advanced search page
   When I check "created_by"
    And I fill in "aidWorker" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should not see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Created By' on both user name and full name
    Given the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | volunteer  | aidWorker            |
      | Peter  | aidWorker  | volunteer            |
    And I am logged in
    And I am on child advanced search page
   When I check "created_by"
    And I fill in "aidWorker" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Created By' - match
    Given the following children exist in the system:
      | name    | created_by |
      | Andrew  | johnny     |
      | Peter   | billy      |
    And I am logged in
    And I am on child advanced search page
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Peter" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "billy" for "created_by_value"
    And I press "Search"
   Then I should see "Peter" in the search results
    And I should not see "Andrew" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Created By' - no match
    Given the following children exist in the system:
      | name    | created_by |
      | Andrew  | johnny     |
      | Peter   | billy      |
    And I am logged in
    And I am on child advanced search page
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Andrew" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "billy" for "created_by_value"
    And I press "Search"
   Then I should see "No results found"
    And I should not see "Andrew" in the search results
    And I should not see "Peter" in the search results


#  UPDATED BY

  @javascript
  Scenario: Validation of 'Updated by'
    Given I am logged in
    When I am on child advanced search page
    And I check "updated_by"
    And I press "Search"
    Then I should see "Please enter a valid 'Updated by' value"

  @javascript
  Scenario: Searching by 'Updated By'
    Given the following children exist in the system:
      | name   | last_updated_by |
      | Andrew | aidWorker       |
      | Peter  | volunteer       |
    And I am logged in
    And I am on child advanced search page
   When I check "updated_by"
    And I fill in "aidWorker" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should not see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Created By' and 'Updated By' - match
    Given the following children exist in the system:
      | name    | created_by | last_updated_by |
      | Andrew  | johnny     | aidWorker       |
      | Peter   | billy      | volunteer       |
    And I am logged in
    And I am on child advanced search page
   When I check "created_by"
    And I fill in "johnny" for "created_by_value"
    And I check "updated_by"
    And I fill in "aidWorker" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should not see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Created By' and 'Updated By' - no match
    Given the following children exist in the system:
      | name    | created_by | last_updated_by |
      | Andrew  | johnny     | aidWorker       |
      | Peter   | billy      | volunteer       |
    And I am logged in
    And I am on child advanced search page
   When I check "created_by"
    And I fill in "johnny" for "created_by_value"
    And I check "updated_by"
    And I fill in "volunteer" for "updated_by_value"
    And I press "Search"
   Then I should see "No results found"
    And I should not see "Andrew" in the search results
    And I should not see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Created By' and 'Updated By' - match
    Given the following children exist in the system:
      | name    | created_by | last_updated_by |
      | Andrew  | johnny     | aidWorker       |
      | Peter   | billy      | volunteer       |
    And I am logged in
    And I am on child advanced search page
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Peter" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "billy" for "created_by_value"
    And I check "updated_by"
    And I fill in "volunteer" for "updated_by_value"
    And I press "Search"
   Then I should see "Peter" in the search results
    And I should not see "Andrew" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Created By' and 'Updated By' - no match
    Given the following children exist in the system:
      | name   | created_by | last_updated_by |
      | Andrew | johnny     | aidWorker       |
      | Peter  | billy      | volunteer       |
    And I am logged in
    And I am on child advanced search page
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Andrew" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "billy" for "created_by_value"
    And I check "updated_by"
    And I fill in "aidWorker" for "updated_by_value"
    And I press "Search"
   Then I should see "No results found"
    And I should not see "Andrew" in the search results
    And I should not see "Peter" in the search results