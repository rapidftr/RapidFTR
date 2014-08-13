@search
Feature: User should be able to list children

  Background:
    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |  birthplace    |
      | andreas  | London              | zubair   | zubairlon123 |  nairobi       |
      | zak      | London              | zubair   | zubairlon456 |  bengal        |
      | jaco     | NYC                 | james    | james456     |  kerala        |
      | meredith | Austin              | james    | james123     |  cairo         |
    And I am logged in as an admin

  Scenario: View link is not available on children listing page
    When I am on the children listing page
    When I click text "rlon456"
    Then I should see "Basic Identity"
    And I should see "rlon456"

  Scenario: Pagination links are not available for less than 20 records
    When I am on the children listing page
    Then I should not see pagination links

  Scenario: Pagination links are available for more than 20 records
    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |  birthplace    |
      | rayn     | London              | zubair   | zubairlon233 |  nairobi       |
      | zakir    | London              | zubair   | zubairlon423 |  bengal        |
      | shaikh   | NYC                 | james    | james423     |  kerala        |
      | marylyn  | Austin              | james    | james124     |  cairo         |
      | jacklyn  | Austin              | james    | james125     |  cairo         |
      | imran    | Austin              | james    | james126     |  cairo         |
      | sachin   | Austin              | james    | james127     |  cairo         |
      | virat    | Austin              | james    | james128     |  cairo         |
      | gambhir  | Austin              | james    | james129     |  cairo         |
      | mahendra | Austin              | james    | james130     |  cairo         |
      | yuvraj   | Austin              | james    | james141     |  cairo         |
      | ashwin   | Austin              | james    | james142     |  cairo         |
      | piyush   | Austin              | james    | james143     |  cairo         |
      | ravindra | Austin              | james    | james144     |  cairo         |
      | ishant   | Austin              | james    | james145     |  cairo         |
      | pujara   | Austin              | james    | james146     |  cairo         |
      | sehwag   | Austin              | james    | james147     |  cairo         |
      | pragyan  | Austin              | james    | james148     |  cairo         |
    When I am on the children listing page
    Then I should see "20" children on the page
    And I should see pagination links for first page

    And I click text "Next →"
    Then I should see "2" children on the page
    And I should see children listing page "2"
    And I should see pagination links for last page

    And I click text "← Previous"
    And I should see children listing page "1"

    And I visit children listing page "2"
    And I should see children listing page "2"

  @javascript
  Scenario: A hidden highlighted field must not be visible in Child Summary
    Given I am on the edit form section page for "basic_identity"
    When I check "fields_protection_status"
    When I am on the children listing page
    Then I should not see "Protection Status"
