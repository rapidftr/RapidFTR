Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  @javascript
  Scenario: Search Criteria - Check presence of required form elements
  Given I am logged in
    And I am on child advanced search page
   Then I should see "Separate words by OR to search for more than one option eg. Tim OR Rahul"
    And I should see "Select A Criteria"
    And I should see "+ add more search options"

  @javascript
  Scenario: Validation of search criteria field name
   Given I am logged in
     And I am on child advanced search page
    When I press "Search"
    Then I should see "Please select a valid field name"

  @javascript
  Scenario: Validation of search criteria field value
   Given I am logged in
     And I am on child advanced search page
    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I press "Search"
    Then I should see "Please enter a valid field value"

  @javascript
  Scenario: Searching by 'Name'
   Given I am logged in
     And I am on child advanced search page
   And the following children exist in the system:
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
  Scenario: Search Filters - Created By - Check presence of required form elements
   Given I am logged in
     And I am on child advanced search page
    Then I should see "Filter Search Results"
     And I should see "Created By:"

  @javascript
  Scenario: Validation of 'Created by'
   Given I am logged in
     And I am on child advanced search page
    When I check "created_by"
     And I press "Search"
    Then I should see "Please enter a valid 'Created by' value"

  @javascript
  Scenario: 'Created By' can only be entered if checkbox selected
   Given I am logged in
     And I am on child advanced search page
    Then the "created_by" checkbox should not be checked
     And the "created_by_value" field should be disabled
    When I check "created_by"
    Then I can fill in "bob" for "created_by_value"

  @javascript
  Scenario: 'Created By' value still present and modifiable after search
   Given I am logged in
     And I am on child advanced search page
    Then the "created_by" checkbox should not be checked
     And the "created_by_value" field should be disabled
    When I check "created_by"
    Then I can fill in "bob" for "created_by_value"
     And I press "Search"
    Then I should see "bob"
     And the "created_by" checkbox should be checked
     And I can fill in "rob" for "created_by_value"

  @javascript
  Scenario: Searching by 'Created By'
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
    Given I am logged in
      And I am on child advanced search page
      And the following children exist in the system:
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
  Scenario: Search Filters - Updated By - Check presence of required form elements
   Given I am logged in
     And I am on child advanced search page
    Then I should see "Filter Search Results"
     And I should see "Updated By:"

  @javascript
  Scenario: Validation of 'Updated by'
   Given I am logged in
     And I am on child advanced search page
    When I check "updated_by"
     And I press "Search"
    Then I should see "Please enter a valid 'Updated by' value"

  @javascript
  Scenario: 'Updated By' can only be entered if checkbox selected
   Given I am logged in
     And I am on child advanced search page
    Then the "updated_by" checkbox should not be checked
     And the "updated_by_value" field should be disabled
    When I check "updated_by"
    Then I can fill in "bob" for "updated_by_value"

  @javascript
  Scenario: 'Updated By' value still present and modifiable after search
   Given I am logged in
     And I am on child advanced search page
    Then the "updated_by" checkbox should not be checked
     And the "updated_by_value" field should be disabled
    When I check "updated_by"
    Then I can fill in "bob" for "updated_by_value"
     And I press "Search"
    Then I should see "bob"
     And the "updated_by" checkbox should be checked
     And I can fill in "rob" for "updated_by_value"

  @javascript
  Scenario: Searching by 'Updated By'
   Given I am logged in
     And I am on child advanced search page
    And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
  Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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
  Scenario: Searching by 'Name', 'Created By' and 'Updated By'
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
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

  @javascript
  Scenario: Search Filters - Date ranges - Check presence of required form elements
   Given I am logged in
     And I am on child advanced search page
    Then I should see "Date Created"
     And I should see "After:"
     And I should see "Before:"
     And I should see "Enter a date (yyyy-mm-dd) in the first box to search records created or updated after that date."
     And I should see "Enter a date (yyyy-mm-dd) in the second box to see records created or updated before that date."
     And I should see "Enter dates in both boxes to see records created between the dates."

  @javascript
  Scenario: Validation of 'Date Created' - entering no date
   Given I am logged in
     And I am on child advanced search page
    When I check "created_at"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'After Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
    When I check "created_at"
     And I fill in "11/12/2012" for "created_at_after_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
    When I check "created_at"
     And I fill in "11/12/2012" for "created_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering both 'After Date' and 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
    When I check "created_at"
     And I fill in "11/12/2012" for "created_at_after_value"
     And I fill in "11/12/2012" for "created_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'After Date' with correct format
   Given I am logged in
     And I am on child advanced search page
    When I check "created_at"
     And I fill in "2012-12-11" for "created_at_after_value"
     And I press "Search"
    Then I should not see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'Before Date' with correct format
    Given I am logged in
      And I am on child advanced search page
     When I check "created_at"
      And I fill in "2012-12-11" for "created_at_before_value"
      And I press "Search"
     Then I should not see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: 'Date Created' (after abd before) can only be entered if checkbox selected
    Given I am logged in
      And I am on child advanced search page
     Then the "created_at" checkbox should not be checked
      And the "created_at_after_value" field should be disabled
      And the "created_at_before_value" field should be disabled
     When I check "created_at"
     Then I can fill in "2012-12-11" for "created_at_after_value"
      And I can fill in "2012-12-12" for "created_at_before_value"

  @javascript
  Scenario: 'Date Created' 'After' and 'Before' values still present and modifiable after search
    Given I am logged in
      And I am on child advanced search page
     Then the "created_at" checkbox should not be checked
      And the "created_at_after_value" field should be disabled
      And the "created_at_before_value" field should be disabled
     When I check "created_at"
     Then I can fill in "2012-12-11" for "created_at_after_value"
      And I can fill in "2012-12-12" for "created_at_before_value"
      And I press "Search"
     Then I should see "2012-12-11"
     Then I should see "2012-12-12"
      And the "created_at" checkbox should be checked
      And I can fill in "2012-12-21" for "created_at_after_value"
      And I can fill in "2012-12-22" for "created_at_before_value"

  @javascript
  Scenario: Searching by 'Date Created' specifying only the 'After' date
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name   | created_at             |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
   When I check "created_at"
    And I fill in "2012-04-23" for "created_at_after_value"
    And I press "Search"
   Then I should not see "Emma" in the search results
    And I should not see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results

  @javascript
  Scenario: Searching by 'Date Created' specifying only the 'Before' date
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name   | created_at             |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
   When I check "created_at"
    And I fill in "2012-04-22" for "created_at_before_value"
    And I press "Search"
   Then I should see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should not see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Date Created' specifying both 'After' and 'Before' dates
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
     | name   | created_at             |
     | Emma   | 2012-04-21 23:59:59UTC |
     | Andrew | 2012-04-22 11:23:58UTC |
     | Peter  | 2012-04-23 03:32:12UTC |
     | James  | 2012-04-24 14:10:03UTC |
   When I check "created_at"
    And I fill in "2012-04-22" for "created_at_after_value"
    And I fill in "2012-04-23" for "created_at_before_value"
    And I press "Search"
   Then I should not see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Name', 'Created By', 'Updated By', and 'Date Created'
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name | created_at             |
      | Willis  | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC |
      | Will    | jane        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC |
      | James   | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC |
      | William | tim         | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC |
      | Wilfred | jane        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC |
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Wil" for "criteria_list[0][value]"
    And I check "created_by"
    And I fill in "john" for "created_by_value"
    And I check "updated_by"
    And I fill in "tim" for "updated_by_value"
    And I check "created_at"
    And I fill in "2012-04-22" for "created_at_after_value"
    And I press "Search"
   Then I should not see "Willis" in the search results
    And I should see "Will" in the search results
    And I should not see "James" in the search results
    And I should not see "William" in the search results
    And I should see "Wilfred" in the search results








