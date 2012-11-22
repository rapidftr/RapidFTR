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


  Scenario: Check the mandatory fields Error messages
    Given I am logged in as an admin

    And I am on create role page
    When I enter the following role details
      | name | description | permissions |
      |     |        |          |

    And I submit the form
    Then I should see error messages


  Scenario: Check Admin cannot create duplicate roles
    Given I am logged in as an admin

    And I am on create role page
    When I enter the following role details
      | name        | description              | permissions |
      | super admin | like an admin, but super | access_all_data   |

    And I submit the form
    And I am on create role page
    When I enter the following role details
      | name        | description              | permissions |
      | super admin | like an admin, but super | access_all_data   |

    And I submit the form
    Then I should see message "A role with that name already exists, please enter a different name"
