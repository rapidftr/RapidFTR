Feature: Test weather each child has a proper change log attached to it.

  @javascript
  Scenario: Validate child creating and initial setting of field

    Given "bob" logs in with "Register Child,Edit Child" permissions
    And someone has entered a child with the name "automation"

    When I follow "Change Log" span
    Then I should see change log of creation by user "bob"
    And I follow "Back"
    Then I follow "Edit" span
    And I fill in "Nationality" with "India"
    And I submit the form
    And I follow "Change Log" span
    Then I should see change log for initially setting the field "Nationality" to value "India" by "bob"

  @javascript
  Scenario: Validate editing a child record

    Given "bob" logs in with "Register Child,Edit Child" permissions
    And someone has entered a child with the name "automation"

    Then I follow "Edit" span
    And I fill in "Birthplace" with "India"
    And I submit the form
    And I follow "Change Log" span
    Then I should see change log for changing value of field "Birthplace" from "Haiti" to value "India" by "bob"

  @javascript
  Scenario: Flagging a record

    Given "bob" logs in with "Register Child,Edit Child" permissions
    And someone has entered a child with the name "automation"


    And I flag as suspect with the following reason:
    """
      He is a bad guy.
    """

    And I follow "Change Log" span
    Then I should see change log for record flag by "bob" for "He is a bad guy."

#  @javascript
  @run
  Scenario: Adding an image

    Given "bob" logs in with "Register Child,Edit Child" permissions
    And someone has entered a child with the name "automation"

    When I follow "Edit"
    And I follow "Photos and Audio"
#    And I wait for 5 seconds
    And I attach a photo "features/resources/jorge.jpg"
    And I submit the form
