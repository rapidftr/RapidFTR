Feature: Suspect Records

  As an admin
  I want to manage flagged records
  
  Background:
  
  Given I am logged in as an admin
  And the following children exist in the system:
     | name   | unique_id  | flag     | flag_message      | investigated |
     | Steve  | steve_uid  | true     | steve is dodgy    | false        |
     | Bob    | bob_uid    | true     | bob is dodgy      | false        |
     | Dave   | dave_uid   | true     | dave is dodgy     | true         |
     | George | george_uid | false    | nil               | false        |

  Scenario: Admin user should see a link on the home page with the details of how many suspect records need attention
  When I am on the home page
  Then I should see "3 Records need Attention"

  Scenario: Admin user should only see flagged children which have not been investigated
  When I am on the child listing filtered by flagged
  Then I should see "Steve"
  And I should see "Bob"
  And I should see "Dave"
  And I should not see "George"

  Scenario: Admin should be able to mark suspect record as investigated
  When I am on the child listing filtered by flagged
  And I follow "Steve"
  Then I should see "Mark as Investigated"

 	Scenario: When an admin user marks a flagged record as investigated it should no longer appear on the suspect record page
  When I am on the child listing filtered by flagged
  And I follow "Steve"
  And I mark "Steve" as investigated with the following details:
    """
    I wouldn't worry about this guy
    """
  Then I should see "Mark as Not Investigated"

  @javascript
  Scenario: Admin should be able to mark investigated record as not investigated
  When I am on the children listing page
  And I follow "Dave"
  Then I should see "Mark as Not Investigated"

  @javascript
  Scenario: When a record is not flagged admin should not be able to mark as investigated or not investigated
  When I am on the children listing page
  And I follow "George"
  Then I should see "Mark as Investigated"
  And I should not see "Mark as Not Investigated"
  
  @javascript
  Scenario: When I mark a record as investigated the change log should display a single entry for the change
  When I am on the child listing filtered by flagged
  And I follow "Steve"
  And I mark "Steve" as investigated with the following details:
    """
    I wouldn't worry about this guy
    """
  And I follow "Change Log" span
  Then I should see "Record was marked as Investigated by admin belonging to UNICEF because: I wouldn't worry about this guy"

  @javascript
  Scenario: When I mark a record as not investigated the change log should display a single entry for the change
  When I am on the children listing page
  And I follow "Dave"
  And I mark "Dave" as not investigated with the following details:
    """
    I don't know what's going on with this record
    """
  And I follow "Change Log" span
  Then I should see "Record was marked as Not Investigated by admin belonging to UNICEF because: I don't know what's going on with this record"
