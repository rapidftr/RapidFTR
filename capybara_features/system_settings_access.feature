Feature: Only users with System Settings permission should have access to certain sections of the site

  Background:
    Given the following form sections exist in the system:
      | name          | description                 | unique_id     | order |
      | Basic Details | Basic details about a child | basic_details | 1     |

  Scenario: An admin can get to all sorts of interesting pages
    Given I am logged in as a user with "System Settings" permission

    Then I should be able to see the admin page
    And I should be able to see the manage users page
    And I should be able to see the form section page
    And I should be able to see the edit form section page for "basic_details"

  Scenario: A normal user can't see administrator stuff
    Given I am logged in
    Then I should not be able to see the admin page
    And I should be able to see manage users page
    And I should not be able to see the form section page
    And I should not be able to see the edit form section page for "basic_details"
