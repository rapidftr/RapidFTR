Feature: Verify in the list of children that
  View link is not available
  Clicking on Child name must open Child Details page

  Background:
    Given I am logged in
    And I am on the children listing page

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |
      | andreas  | London              | zubair   | zubairlon123 |
      | zak      | London              | zubair   | zubairlon456 |
      | jaco     | NYC                 | james    | james456     |
      | meredith | Austin              | james    | james123     |

    When I am on the children listing page
    Then I should not see "view"

    When I click text "andreas"
    Then I should see "Basic Identity"
    And I should see "andreas"

