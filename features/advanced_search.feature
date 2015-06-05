@search
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search to find all relevant results

  @javascript
  Scenario: Validation of search criteria field name
   Given I am logged in
   And I am on child advanced search page
   When I search
   And I wait for the page to load
   Then I should see "Please enter at least one search criteria"

  @javascript
  Scenario: Validation of search criteria field value
    Given I am logged in
    And I am on child advanced search page
    When I click text "Select A Criteria"
    And  I click text "Name"
    And  I search
    And I wait for the page to load
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
    And I fill in "criteria_list[0][value]" with "Will"
    And I search
    And I wait for the page to load
    Then I should see "Will" in the search results
    And I should see "Willis" in the search results
    When I clear the search results
    Then I should not see "Will" in the search results
    And I should not see "Willis" in the search results

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
    And I search
    And I wait for the page to load
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
    And I search
    And I wait for the page to load
    Then I click text "Sex"
    And I click text "Name"
    Then I fill in "criteria_list[0][value]" with "mary"
    Then I search
    And I wait for the page to load
    And I should see "mary" in the search results

  Scenario: Searching by 'Created By' - fuzzy search
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name   | created_by | created_by_full_name |
      | Andrew | bob        | john                 |
      | Peter  | john       | bob                  |
      | James  | john       | john                 |
    When I fill in "created_by_value" with "bob"
    And I search
    And I wait for the page to load
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
    And I fill in "criteria_list[0][value]" with "Andrew"
    And I fill in "created_by_value" with "bob"
    And I search
    And I wait for the page to load
    Then I should see "Andrew1" in the search results
    And I should see "Andrew2" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Validation of 'Date Created' - entering 'After Date' with incorrect format
    Given I am logged in
    And I am on child advanced search page
    And I fill in "created_at_after_value" with "11/12/2012"
    And I search
    And I wait for the page to load
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  @javascript
  Scenario: Validation of 'Date Created' - entering 'Before Date' with incorrect format
    Given I am logged in
    And I am on child advanced search page
    And I fill in "created_at_before_value" with "11/12/2012"
    And I search
    And I wait for the page to load
    Then I should see "Please enter a valid 'After' and/or 'Before' Date Created (format yyyy-mm-dd)."

  Scenario: Searching by 'Date Created' specifying only the 'After' date
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name   | created_at             |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
    And I fill in "created_at_after_value" with "2012-04-23"
    And I search
    And I wait for the page to load
    Then I should not see "Emma" in the search results
    And I should not see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results

  Scenario: Searching by 'Date Updated' specifying only the 'After' date
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name   | last_updated_at        |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
    And I fill in "updated_at_after_value" with "2012-04-23"
    And I search
    And I wait for the page to load
    Then I should not see "Emma" in the search results
    And I should not see "Andrew" in the search results
    And I should see "Peter" in the search results
    And I should see "James" in the search results

  Scenario: Searching by 'Date Updated' specifying both 'After' and 'Before' dates
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name   | created_at             |
      | Emma   | 2012-04-21 23:59:59UTC |
      | Andrew | 2012-04-22 11:23:58UTC |
      | Peter  | 2012-04-23 03:32:12UTC |
      | James  | 2012-04-24 14:10:03UTC |
    And I fill in "updated_at_after_value" with "2012-04-22"
    And I fill in "updated_at_before_value" with "2012-04-23"
    And I search
    And I wait for the page to load
    Then I should not see "Emma" in the search results
    And I should see "Andrew" in the search results
    And I should not see "Peter" in the search results
    And I should not see "James" in the search results

  @javascript
  Scenario: Searching by 'Name', 'Created By', 'Updated By', 'Date Created', and 'Date Updated'
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name | created_at             |
      | Willis  | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC |
      | Wilbert | jane        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC |
      | James   | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC |
      | William | tim         | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC |
      | Wilfred | jane        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC |
    When I click text "Select A Criteria"
    And I click text "Name"
    And I fill in "criteria_list[0][value]" with "Wil"
    And I fill in "created_by_value" with "bob"
    And I fill in "updated_by_value" with "jan"
    And I fill in "created_at_after_value" with "2012-04-22"
    And I fill in "created_at_before_value" with "2012-04-24"
    And I fill in "updated_at_after_value" with "2012-04-21"
    And I fill in "updated_at_before_value" with "2012-05-24"
    And I search
    And I wait for the page to load
    Then I should not see "Willis" in the search results
    And I should not see "Wilbert" in the search results
    And I should not see "James" in the search results
    And I should see "William" in the search results
    And I should not see "Wilfred" in the search results

  @javascript @wip @passinglocally
  Scenario: Searching by 'Protection Status', bug 1664
    Given I am logged in
    And I am on the child advanced search page
    And the following children exist in the system:
      | name    | protection_status | created_by  |
      | Willis  | Unaccompanied     | john        |
      | Wilbert | Separated         | jane        |
      | James   | Unaccompanied     | john        |
      | William | Separated         | tim         |
    When I click text "Select A Criteria"
    And I click text "Protection Status"
    And I select "Separated" from "criteria_list[0][value]"
    And I search
    Then I should see "Wilbert" in the search results
    Then I should see "William" in the search results
    Then I should not see "Willis" in the search results
    Then I should not see "James" in the search results
    And I select "Unaccompanied" from "criteria_list[0][value]"
    And I search
    Then I should not see "Wilbert" in the search results
    Then I should not see "William" in the search results
    Then I should see "Willis" in the search results
    Then I should see "James" in the search results


  Scenario: Add Paging to advanced search page
    Given I am logged in
    And I am on child advanced search page
    And the following children exist in the system:
      | name    | created_by  | created_by_full_name | last_updated_by | last_updated_by_full_name | created_at             | last_updated_at        |
      | Willis  | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Wilbert | john        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | James   | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | William | john        | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Wilfred | john        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |
      | Jerry   | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Harry   | john        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | Emily   | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Watson  | john        | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | George  | john        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |
      | Jack    | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Tim     | john        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | Rachel  | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Kiaani  | john        | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Sam     | john        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |
      | Will    | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Ricky   | john        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | Polard  | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Fiere   | john        | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Richard | john        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |
      | Johnson | john        | bob                  | tim             | jane                      | 2012-04-21 23:59:59UTC | 2012-05-21 23:59:59UTC |
      | Yaxuan  | jane        | john                 | bob             | tim                       | 2012-04-22 11:23:58UTC | 2012-05-22 11:23:58UTC |
      | Nick    | john        | bob                  | tim             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Diana   | john        | bob                  | bob             | jane                      | 2012-04-23 03:32:12UTC | 2012-05-23 03:32:12UTC |
      | Rubel   | john        | john                 | bob             | tim                       | 2012-04-24 14:10:03UTC | 2012-05-24 14:10:03UTC |

    When I fill in "created_by_value" with "john"
    And I search
    And I wait for the page to load
    Then I should see first 20 records in the search results

    When I goto the "next_page"
    Then I should see next records in the search results
    And I should see link to "next_page disabled"

    When I goto the "previous_page"
    Then I should see first 20 records in the search results
    And I should see link to "previous_page disabled"
