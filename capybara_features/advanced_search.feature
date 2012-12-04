Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  @javascript
  Scenario: Search Criteria - Check presence of required form elements
  Given I am logged in
    And I am on child advanced search page
    Then I should see "Separate words by OR to search for more than one option eg. Tim OR Rahul"
    And I should see "Select A Criteria"

  @javascript
  Scenario: Validation of search criteria field name
   Given I am logged in
     And I am on child advanced search page
    When I press "Search"
    Then I should see "Please enter at least one search criteria"

  @javascript
  Scenario: Validation of search criteria field value
   Given I am logged in
     And I am on child advanced search page
    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I press "Search"
    Then I should see "Please enter a valid field value."

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
  Scenario: Searching by a dropdown field
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name    | gender           |
      | Andrew  | Male             |
      | mary    | Female           |
    When I click text "Select A Criteria"
    And I click text "Sex"
    And I select "Male" from "criteria_list[0][value]"
    And I press "Search"
    Then I should see "Andrew" in the search results
    And I should not see "mary" in the search results

    @javascript
    Scenario: Change the existing search criteria after a Search is performed
      Given I am logged in
      And I am on child advanced search page
      And the following children exist in the system:
        | name    | gender           |
        | Andrew  | Male             |
        | mary    | Female           |
      When I click text "Select A Criteria"
      And I click text "Sex"
      And I select "Male" from "criteria_list[0][value]"
      And I press "Search"
      Then I click text "Sex"
      And I click text "Name"
      Then I fill in "mary" for "criteria_list[0][value]"
      Then I press "Search"
      And I should see "mary" in the search results

  @javascript
  Scenario: Searching by 'Created By'
   Given I am logged in
     And I am on child advanced search page
    Then I wait for 7 seconds
     And the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob        | john                 |
      | Peter  | john       | bob                  |
      | James  | john       | john                 |
    And I fill in "bob" for "created_by_value"
    And I press "Search"
    Then I should see "Andrew" in the search results

  @javascript
  Scenario: Searching by 'Created By'
   Given I am logged in
     And I am on child advanced search page
    Then I wait for 2 seconds
     And the following children exist in the system:
       | name   | created_by | created_by_full_name | created_organisation |
       | Andrew | bob        | john                 | stc                  |
       | Peter  | john       | bob                  | unicef               |
       | James  | john       | john                 | unicef               |
    Then I fill in "stc" for "created_by_organisation_value"
    And I press "Search"
    Then I should see "Andrew" in the search results

  @javascript
  Scenario: Searching by 'Created By' - fuzzy search
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob        | john                 |
      | Peter  | john       | bob                  |
      | James  | john       | john                 |
    Then I fill in "rob" for "created_by_value"
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
    Then I fill in "bob OR jane" for "created_by_value"
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
      | Andrew | bob_jane   | john                 |
      | Peter  | john       | jane bob             |
      | James  | bob        | jane                 |
      | David  | tim        | tom                  |
    Then I fill in "bob AND jane" for "created_by_value"
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
      | Andrew | bob_smith_jane | john                 |
      | Peter  | john           | bob jane smith       |
      | James  | bob            | smith                |
    Then I fill in "bob smith" for "created_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  # This fails routinely in Travis with a TimeoutError in CouchRest
  @javascript @wip
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
     And I fill in "bob" for "created_by_value"
     And I press "Search"
    Then I should see "Andrew1" in the search results
     And I should see "Andrew2" in the search results
     And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Updated By'
   Given I am logged in
     And I am on child advanced search page
    And the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob             | john                      |
      | Peter  | john            | bob                       |
      | James  | john            | john                      |
    And I fill in "bob" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  
  @javascript
  Scenario: Searching by 'Updated By' - fuzzy search
   Given I am logged in
     And I am on child advanced search page
    And the following children exist in the system:
      | name   | last_updated_by | last_updated_by_full_name |
      | Andrew | bob             | john                      |
      | Peter  | john            | bob                       |
      | James  | john            | john                      |
    Then I fill in "rob" for "updated_by_value"
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
      | Andrew | bob_smith_jane  | john                      |
      | Peter  | john            | bob jane smith            |
      | James  | bob             | smith                     |
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
    And I fill in "john" for "created_by_value"
    And I fill in "tim" for "updated_by_value"
    And I press "Search"
   Then I should see "Andrew" in the search results

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
    And I fill in "john" for "created_by_value"
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
    And I fill in "john" for "created_by_value"
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
    Then I should see "Enter a date (yyyy-mm-dd) in the first box to search records created or updated after that date."
     And I should see "Enter a date (yyyy-mm-dd) in the second box to see records created or updated before that date."
     And I should see "Enter dates in both boxes to see records created between the dates."
     And I should see "Date Created"
     And I should see "After:"
     And I should see "Before:"
     And I should see "Date Updated"
     And I should see "After:"
     And I should see "Before:"

  @javascript
  Scenario: Validation of 'Date Created' - entering 'After Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "created_at_after_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "created_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering both 'After Date' and 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "created_at_after_value"
     And I fill in "11/12/2012" for "created_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'After Date' with correct format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "2012-12-11" for "created_at_after_value"
     And I press "Search"
    Then I should not see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'Before Date' with correct format
    Given I am logged in
      And I am on child advanced search page
      And I fill in "2012-12-11" for "created_at_before_value"
      And I press "Search"
     Then I should not see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: 'Date Created' 'After' and 'Before' values can only be entered if checkbox selected
    Given I am logged in
      And I am on child advanced search page
     Then the "created_at" checkbox should not be checked
      And the "created_at_after_value" field should be disabled
      And the "created_at_before_value" field should be disabled
     Then I can fill in "2012-12-11" for "created_at_after_value"
      And I can fill in "2012-12-12" for "created_at_before_value"

  @javascript
  Scenario: 'Date Created' 'After' and 'Before' values still present and modifiable after search
    Given I am logged in
      And I am on child advanced search page
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
    And I fill in "2012-04-22" for "created_at_after_value"
    And I fill in "2012-04-23" for "created_at_before_value"
    And I press "Search"
   Then I should not see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Validation of 'Date Updated' - entering no date
   Given I am logged in
     And I am on child advanced search page
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Updated' - entering 'After Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "updated_at_after_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Updated' - entering 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "updated_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Updated' - entering both 'After Date' and 'Before Date' with incorrect format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "11/12/2012" for "updated_at_after_value"
     And I fill in "11/12/2012" for "updated_at_before_value"
     And I press "Search"
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Updated' - entering 'After Date' with correct format
   Given I am logged in
     And I am on child advanced search page
     And I fill in "2012-12-11" for "updated_at_after_value"
     And I press "Search"
    Then I should not see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Updated' - entering 'Before Date' with correct format
    Given I am logged in
      And I am on child advanced search page
      And I fill in "2012-12-11" for "updated_at_before_value"
      And I press "Search"
     Then I should not see "Please enter a valid 'After' and/or 'Before' Date Updated (format yyyy-mm-dd)."

  @javascript
  Scenario: Searching by 'Date Updated' specifying only the 'After' date
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name   | last_updated_at        |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
    And I fill in "2012-04-23" for "updated_at_after_value"
    And I press "Search"
   Then I should not see "Emma" in the search results
    And I should not see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results

  @javascript
  Scenario: Searching by 'Date Updated' specifying only the 'Before' date
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name   | last_updated_at        |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
    And I fill in "2012-04-22" for "updated_at_before_value"
    And I press "Search"
   Then I should see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should not see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Date Updated' specifying both 'After' and 'Before' dates
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
     | name   | last_updated_at        |
     | Emma   | 2012-04-21 23:59:59UTC |
     | Andrew | 2012-04-22 11:23:58UTC |
     | Peter  | 2012-04-23 03:32:12UTC |
     | James  | 2012-04-24 14:10:03UTC |
    And I fill in "2012-04-22" for "updated_at_after_value"
    And I fill in "2012-04-23" for "updated_at_before_value"
    And I press "Search"
   Then I should not see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Name', 'Created By', 'Updated By', 'Date Created', and 'Date Updated'
   Given I am logged in
     And I am on child advanced search page
     And the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name | created_at             | last_updated_at        |
      | Willis  | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Wilbert | jane        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | James   | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | William | tim         | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Wilfred | jane        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |
   When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "Wil" for "criteria_list[0][value]"
    And I fill in "bob" for "created_by_value"
    And I fill in "jan" for "updated_by_value"
    And I fill in "2012-04-22" for "created_at_after_value"
    And I fill in "2012-04-24" for "created_at_before_value"
    And I fill in "2012-05-21" for "updated_at_after_value"
    And I fill in "2012-05-23" for "updated_at_before_value"
    And I press "Search"
   Then I should not see "Willis" in the search results
    And I should not see "Wilbert" in the search results
    And I should not see "James" in the search results
    And I should see "William" in the search results
    And I should not see "Wilfred" in the search results








