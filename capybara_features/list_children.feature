Feature: Verify in the list of children that
  View link is not available
  Clicking on Child name must open Child Details page

  Background:
    Given I am logged in as an admin
    And I am on the children listing page

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |  birthplace    |
      | andreas  | London              | zubair   | zubairlon123 |  nairobi       |
      | zak      | London              | zubair   | zubairlon456 |  bengal        |
      | jaco     | NYC                 | james    | james456     |  kerala        |
      | meredith | Austin              | james    | james123     |  cairo         |


    When I am on the children listing page
    Then I should not see "view"

    When I click text "andreas"
    Then I should see "Basic Identity"
    And I should see "andreas"

    @javascript
  Scenario: A hidden highlighted field must not be visible in Child Summary
    Given I am on the edit form section page for "basic_identity"
    When I check "fields_birthplace"
      Then I "Hide" selected form fields
      Then I wait for 10 seconds
      When I am on the children listing page
      Then I wait for 20 seconds
    Then I should not see "birthplace"
