Feature:

  As a user
  I want to go to flag a child's record
  So that I can identify suspect and duplicate records to admin


  Scenario: Flagging a child record
    Given I am logged in
    And the following children exist in the system:
      | name   |
      | Peter |
    When I flag the record as suspect with the following reason:
      """
      He is a bad guy.
      """
    Then the view record page should show the record is flagged
    And the edit record page should show the record is flagged
    And the record history should log "Record flagged"
    And the record history should log "He is a bad guy"
    
  Scenario: Removing flag from a child record
    Given I am logged in
    And the following children exist in the system:
      | name   |
      | Peter  |
    When I flag the record as suspect with the following reason:
      """
      He is a bad guy.
      """
    When I am on the child record page for "Peter"
    And I follow "Unflag record"
    Then I should see "Flag record as suspect"
    And the record history should log "Flag was removed"

    