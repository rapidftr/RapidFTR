Feature: Add new role

  Scenario: Adding new role
    Given I am logged in as a user with "Admin" permission

    And I am on create role page 
    When I enter the following role details
      | name        | description              | permissions       |
      | super admin | like an admin, but super | admin             |

    And I submit the form
    Then I should be on roles index page
    And I should see the following roles
      | name        | description              | permissions       |
      | super admin | like an admin, but super | admin             |

  @javascript
  Scenario: Filtering by role
    Given I am logged in as a user with "Admin" permission
    And I am on create role page    
		And I enter the following role details
      | name           | description              | permissions       |
      | Can Edit Child | can edit child           | edit_child        |
    And I submit the form

    When I try to filter user roles by permission "Edit Child"

    Then I should see the following roles
    | name           | description    | permissions |
    | Can Edit Child | can edit child | edit_child  |