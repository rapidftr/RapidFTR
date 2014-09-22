Feature: Only users with System Settings permission should have access to certain sections of the site

  Background:
    Given the following form sections exist in the system on the "Children" form:
      | name          | description                 | unique_id     | order |
      | Basic Details | Basic details about a child | basic_details | 1     |

  Scenario: An admin can get to all sorts of interesting pages
    Given I am logged in as a user with "System Settings" permission

    Then I should be able to see the admin page
    And I should be able to see the manage users page
    And I should be able to see the form sections page for "Children"
    And I should be able to see the edit form section page for "basic_details"

  Scenario: A normal user can't see administrator stuff
    Given I am logged in
    Then I should not be able to see the admin page
    And I should be able to see manage users page
    And I should not be able to see the form sections page for "Children"
    And I should not be able to see the edit form section page for "basic_details"

  Scenario: An admin can view a list of system variables
    Given the following system variables exist in the system
      | name                         | value |
      | SOLR_SCORE_THRESHOLD         | 2.0   |
      | USER_SESSION_TIMEOUT_MINUTES | 20    |
    Given I am logged in as an admin
    And I follow "System Settings"
    And I follow "System Variables"
    Then I should see "Manage System Variables"
    And I should see "SOLR_SCORE_THRESHOLD"
    And I should see "USER_SESSION_TIMEOUT_MINUTES"




