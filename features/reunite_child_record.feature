Feature:

  As a user
  I want to mark a child as reunited
  So that I don’t have to spend resources finding and reuniting a child that’s no longer separated

  Background:
   Given "Praful" is logged in
   And the following children exist in the system:
      | name   |
      | Peter |

  Scenario: Reunite a child record
    When I reunite "Peter" with the reason "Found his parents."
    Then I should see "Child was successfully updated."
    And the record history should log "Child status changed to reunited by praful with these details: Found his parents"

  Scenario: Undo Reuniting from a child record
    Given I reunite "Peter" with the reason "Found his parents."
    When I am on the child record page for "Peter"
    And I undo reunite "Peter" with the reason "Those were his fake parents."
    Then I should see "Child was successfully updated."
    And the record history should log "Child status changed to active by praful with these details: Those were his fake parents."
