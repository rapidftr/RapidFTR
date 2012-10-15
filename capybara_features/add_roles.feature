Feature: Add new role

  Scenario: Adding new role
    Given I am logged in as an admin

    And I am on create role page 
    When I enter the following role details
      | name        | description              | permissions |
      | super admin | like an admin, but super | access_all_data   |

    And I submit the form

    Then I should be on roles index page
    And I see the following roles
      | name        | description              | permissions |
      | super admin | like an admin, but super | access_all_data   |

