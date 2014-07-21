Feature:

  As a user
  I want to go to flag a child's record
  So that I can identify suspect and duplicate records to admin

  Background:
   Given "Praful" logs in with "Edit Child,View And Search Child,Export to Photowall/CSV/PDF" permissions
   And the following children exist in the system:
      | name   | unique_id |
      | Peter  | id_1      |

  @javascript
  Scenario: Flagging a child record
    When I am on the child record page for "Peter"
    And I flag as suspect with the following reason:
      """
      He is a bad guy.
      """
    Then the view record page should show the record is flagged
    And the edit record page should show the record is flagged
    And the record history should log "Record was flagged by praful belonging to UNICEF because: He is a bad guy."
    And the child listing page filtered by flag should show the following children:
      | id_1 |
    When I am on the children listing page
    Then I should see "Flagged By"

#    And I follow "View All Children"
#    Then I should see flagged details
  @javascript
  Scenario: Removing flag from a child record
    Given I flag "Peter" as suspect
    When I am on the child record page for "Peter"
    And I unflag "Peter" with the following reason:
      """
      He is a not such a bad guy after all.
      """
    Then I should see "Child was successfully updated."
    And the record history should log "Record was unflagged by praful belonging to UNICEF because: He is a not such a bad guy after all."
    When I am on the children listing page
    Then I should not see "Flagged By"

  @javascript @search
  Scenario: Seeing Flagged Child in Search Results
    Given the following children exist in the system:
        | name   | flag  |
        | Peggy  | false |
    And I flag "Peter" as suspect
    When I search using a name of "Pe"
    Then the "Peter" result should have a "suspect" image

  @javascript
  Scenario: Flagging a child record from listing page.
    When I am on the children listing page
    And I should not see "Flagged By" for record "Peter"
    And I flag "Peter" as suspect with the following reason:
    """
      He is a bad guy.
      """
    Then I should see "Flagged By" for record "Peter"
    And the record history should log "Record was flagged by praful belonging to UNICEF because: He is a bad guy."
    And the child listing page filtered by flag should show the following children:
      | id_1 |
