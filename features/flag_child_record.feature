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
    And the record history should log a change to "flag"