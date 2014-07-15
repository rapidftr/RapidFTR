Feature: Merge Child Records

  As a Field Worker
  I want to Merge duplicate records together
  So that I don't waste time working on two identical records

  Background:

   Given I am logged in as an admin
   And the following children exist in the system:
     | name   | unique_id  | flag    |flagged_at                   | short_id |
     | Bob    | bob_uid    | true    |DateTime.new(2001,2,3,4,5,6) | bob_uid  |
     | Steve  | steve_uid  | true    |DateTime.new(2004,2,3,4,5,6) | eve_uid  |
     | Dave   | dave_uid   | true    |DateTime.new(2002,2,3,4,5,6) | ave_uid  |
     | Fred   | fred_uid   | false   |DateTime.new(2003,2,3,4,5,6) | red_uid  |

  @javascript
  Scenario: Should see the "Mark as Duplicate" link on the Suspect Records Page
    When I am on the child listing filtered by flag
    And I select dropdown option "Flagged"
    Then I should see "Mark as Duplicate"

  @javascript
  Scenario: Should see duplicate page when I click on "Mark as Duplicate"
    When I am on the child listing filtered by flag
    And I select dropdown option "Flagged"
    And I click mark as duplicate for "Steve"
    Then I am on duplicate child page for "Steve"

# This test is causing Firefox to crash (Firefox v19, selenium-webdriver v2.30.0)
#  @javascript
#  Scenario: Should see view child page when I click OK on confirmation
#    When I am on the child listing filtered by flagged
#    And I select dropdown option "Flagged"
#    And I click mark as duplicate for "Steve"
#    And I fill in "parent_id" with "red_uid"
#    And I press "Mark as Duplicate"
#    Then I am on the child record page for "Steve"
#    And I should see "This record has been marked as a duplicate and is no longer active. To see the Active record click here."

  Scenario: Should see duplicate message when viewing child record
    And "Bob" is a duplicate of "Dave"
    When I am on the child record page for "Dave"
    Then I should see "Another record has been marked as a duplicate of this one. Click here to see the duplicate record."
    And I follow "here"
    Then I am on the child record page for unique id "bob_uid"

# This test is causing Firefox to crash (Firefox v19, selenium-webdriver v2.30.0)
#   @javascript
#   Scenario: Should see error message when wrong Duplicate id/name is given
#     When I am on the child listing filtered by flagged
#     And I select dropdown option "Flagged"
#     And I click mark as duplicate for "Steve"
#     And I fill in "parent_id" with "fred_uid"
#     And I press "Mark as Duplicate"
#     And I should see "This is not a valid rapidftr id."
