Feature: Merge Child Records

  As a Field Worker
  I want to Merge duplicate records together
  So that I don't waste time working on two identical records
  
  Background:

   Given I am logged in as an admin
   And the following children exist in the system:
     | name   | unique_id  | reunited | flag    | duplicate |
     | Bob    | bob_uid    | false    | true    | true      |
     | Steve  | steve_uid  | false    | true    | false     |
     | Dave   | dave_uid   | true     | true    | false     |
     | Fred   | fred_uid   | true     | false   | false     |

  Scenario: Should see the "Mark as Duplicate" link on the Suspect Records Page
    When I am on the suspect records page
    Then I should see "Mark as Duplicate"
    
  Scenario: Should see duplicate page when I click on "Mark as Duplicate"
    When I am on the suspect records page
    And I click mark as duplicate for "Steve"
    Then I am on duplicate child page for "Steve"
    
  Scenario: Should see view child page when I click OK on confirmation
    When I am on the suspect records page
    And I click mark as duplicate for "Steve"
    And I fill in "fred_uid" for "parent_id"
    And I press "Mark as duplicate"
    Then I am on the child record page for "Steve"
    And I should see "This record has been marked as a duplicate and is no longer active."
    
  Scenario: Should see "Duplicate Record" when I view a duplicate record
    When I am on the child record page for "Bob"
    Then I should see "This record has been marked as a duplicate and is no longer active. To see the Active record click here."