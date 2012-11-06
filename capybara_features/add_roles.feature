Feature: Add new role

  Scenario: Adding new role
    Given I am logged in as a user with "Admin" permission

    And I am on create role page 
    When I enter the following role details
      | name        | description              | permissions       |
      | super admin | like an admin, but super | admin             |

    And I submit the form
    Then I should be on roles index page
    And I see the following roles
      | name        | description              | permissions       |
      | super admin | like an admin, but super | admin             |
