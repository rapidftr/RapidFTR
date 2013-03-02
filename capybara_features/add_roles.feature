Feature: Add new role

  Scenario: Adding new role
    Given I am logged in as a user with "Admin" permission

    And I am on create role page 
    When I enter the following role details
      | name        | description              | permissions       |
      | super admin | like an admin, but super | system_settings   |

    And I submit the form
    Then I should be on roles index page
    And I should see the following roles
      | name        | description              | permissions       |
      | super admin | like an admin, but super | system_settings   |

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

  @javascript
  @roles
  Scenario: Sorting by Ascending Order
    Given I am logged in as a user with "Admin" permission
    When I try to filter user roles sorted by "Ascending"
    Then I should see the following roles sorted:
      |name         |
      |Admin        |
      |Field Admin  |
      |Field Worker |

  @javascript
  @roles
  Scenario: Sorting by Descending Order
    Given I am logged in as a user with "Admin" permission
    When I try to filter user roles sorted by "Descending"
    Then I should see the following roles sorted:
      |name         |
      |Field Worker |
      |Field Admin  |
      |Admin        |

@javascript
@roles

    Scenario:Editing a newly created role
   Given I am logged in as a user with "Admin" permission
   And I am on create role page
    And I enter the following role details
      | name           | description              | permissions       |
      | Automation Role | can edit child           | view_users        |
    And I submit the form
    When I edit the role Automation Role
   And I enter the following permission details
       | permissions       |
       | register_child        |
       | view_and_search_child |
       | view_roles             |
       | edit_child             |
       | create_and_edit_users  |
    And I update the form
   And I am on manage users page
   And I follow "Create User"
   When I fill in the following:
     | Full Name         | Test Automation     |
     | User Name         | Automation          |
     | Password          | automation |
     | Re-enter password | automation |
     | Organisation      | UNICEF       |

   And I check "Automation role"
   And I press "Create"
   And I logout
   Then I am logged in as user automation with password as automation
   Then I should be able to view the tab USERS
   And I should be able to view the tab REPORTS
   And I should be able to view the tab CHILDREN
   And I logout
   Then I am logged in as user mary with password as 123
   And I am on the manage users page
   Then user "automation" should exist on the page
   Then I should see "Edit" for "automation"
   Then I should see "Delete" for "automation"



