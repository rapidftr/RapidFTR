Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  Background:
   Given I am logged in
   And I am on child advanced search page

  @javascript
  Scenario: Check presence of required form elements
   Then I should see "Separate words by OR to search for more than one option eg. Tim OR Rahul"
    And I should see "Select A Criteria"
    And I should see "+ add more search options"
    And I should see "Filter Search Results"
    And I should see "Created By:"
    And I should see "Updated By:"

  @javascript
  Scenario: Validation of search criteria field name
    When I press "Search"
    Then I should see "Please select a valid field name"

  @javascript
  Scenario: Validation of search criteria field value
    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I press "Search"
    Then I should see "Please enter a valid field value"

  @javascript
  Scenario: Searching by 'Name'
   Given the following children exist in the system:
      | name   |
      | Willis |
      | Will   |
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Will" for "criteria_list[0][value]"
    And I press "Search"
   Then I should see "Will" in the search results
    And I should see "Willis" in the search results

  @javascript
  Scenario: Validation of 'Created by'
   When I check "created_by"
    And I press "Search"
   Then I should see "Please enter a valid 'Created by' value"

  @javascript
  Scenario: Searching by 'Created By'
    Given the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob        | john                 |
      | Peter  | john       | bob                  |
      | James  | john       | john                 |
   When I check "created_by"
    And I fill in "bob" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Created By' - OR search
    Given the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob        | john                 |
      | Peter  | john       | jane                 |
      | James  | john       | john                 |
   When I check "created_by"
    And I fill in "bob OR jane" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Created By' - AND search
    Given the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob jane   | john                 |
      | Peter  | john       | jane bob             |
      | James  | bob        | jane                 |
      | David  | tim        | tom                  |
   When I check "created_by"
    And I fill in "bob AND jane" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results
    And I should not see "David" in the search results

  @javascript
  Scenario: Searching by 'Created By' - search with two terms
    Given the following children exist in the system:
      | name   | created_by     | created_by_full_name |
      | Andrew | bob smith jane | john                 |
      | Peter  | john           | bob jane smith       |
      | James  | bob            | smith                |
   When I check "created_by"
    And I fill in "bob smith" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
   Scenario: Searching by 'Name' and 'Created By'
     Given the following children exist in the system:
       | name    | created_by  | created_by_full_name |
       | Andrew1 | bob         | john                 |
       | Andrew2 | john        | bob                  |
       | James   | bob         | smith                |
    When I click text "Select A Criteria"
     And I click text "Name"
     And I fill in "Andrew" for "criteria_list[0][value]"
     And I check "created_by"
     And I fill in "bob" for "created_by_value"
     And I press "Search"
    Then I should see "Andrew1" in the search results
     And I should see "Andrew2" in the search results
     And I should not see "James" in the search results

  @javascript
  Scenario: Validation of 'Updated by'
    When I check "updated_by"
     And I press "Search"
    Then I should see "Please enter a valid 'Updated by' value"

  @javascript
  Scenario: Searching by 'Updated By'
   Given the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob             | john                      |
      | Peter  | john            | bob                       |
      | James  | john            | john                      |
   When I check "updated_by"
    And I fill in "bob" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Updated By' - OR search
   Given the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob             | john                      |
      | Peter  | john            | jane                      |
      | James  | john            | john                      |
   When I check "updated_by"
    And I fill in "bob OR jane" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Updated By' - AND search
   Given the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob jane        | john                      |
      | Peter  | john            | jane bob                  |
      | James  | bob             | jane                      |
      | David  | tim             | tom                       |
   When I check "updated_by"
    And I fill in "bob AND jane" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results
    And I should not see "David" in the search results

  @javascript
  Scenario: Searching by 'Updated By' - search with two terms
   Given the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob smith jane  | john                      |
      | Peter  | john            | bob jane smith            |
      | James  | bob             | smith                     |
   When I check "updated_by"
    And I fill in "bob smith" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Updated By'
    Given the following children exist in the system:
       | name    | last_updated_by | last_updated_by_full_name |
       | Andrew1 | bob             | john                      |
       | Andrew2 | john            | bob                       |
       | James   | bob             | smith                     |
    When I click text "Select A Criteria"
     And I click text "Name"
     And I fill in "Andrew" for "criteria_list[0][value]"
     And I check "updated_by"
     And I fill in "bob" for "updated_by_value"
     And I press "Search"
    Then I should see "Andrew1" in the search results
     And I should see "Andrew2" in the search results
     And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Created By' and 'Updated By' - match on user names
   Given the following children exist in the system:
      | name    | created_by  | last_updated_by |
      | Andrew  | john        | tim             |
   When I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results

  @javascript
  Scenario: Searching by 'Created By' after un-checking 'Updated By'
   Given the following children exist in the system:
      | name    | created_by  | last_updated_by |
      | Andrew  | john        | tim             |
      | James   | john        | tom             |
      | Peter   | jane        | tom             |
   When I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I uncheck "updated_by"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "James" in the search results
    And I should not see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Updated By' after un-checking 'Created By'
   Given the following children exist in the system:
      | name    | created_by  | last_updated_by |
      | Andrew  | john        | tim             |
      | James   | john        | tom             |
      | Peter   | jane        | tim             |
   When I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I uncheck "created_by"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should not see "James" in the search results
    And I should see "Peter" in the search results

  @javascript
  Scenario: Searching by 'Created By' and 'Updated By' - match on user names and full names
   Given the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name |
      | Andrew  | john        | bob                  | tim             | jane                      |
      | Peter   | jane        | john                 | bob             | tim                       |
      | James   | tim         | jane                 | john            | bob                       |
      | David   | bob         | tim                  | jane            | john                      |
   When I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results
    And I should not see "David" in the search results

  @javascript
  Scenario: Searching by 'Name' and 'Created By' and 'Updated By'
   Given the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name |
      | Willis  | john        | bob                  | tim             | jane                      |
      | Will    | jane        | john                 | bob             | tim                       |
      | James   | john        | bob                  | tim             | jane                      |
      | William | tim         | bob                  | bob             | jane                      |
      | Wilfred | jane        | john                 | bob             | tim                       |
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Wil" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I press "Search"
   Then I should see "Willis" in the search results
    And I should see "Will" in the search results
    And I should not see "James" in the search results
    And I should not see "William" in the search results
    And I should see "Wilfred" in the search results







