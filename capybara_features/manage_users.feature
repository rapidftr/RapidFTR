Feature: Manage Users

#Story: Changing user disabled status from user list page

  @javascript
  @wip
  Scenario: Admins should be able to change user disabled status from index page
    Given a user "homersimpson"
      And user "homersimpson" is disabled
      And I am logged in as an admin
      And I follow "Admin"
      And I follow "Manage Users"
     When I uncheck the disabled checkbox for user "homersimpson"
     Then user "homersimpson" should not be disabled

#Story 745: Create "Limited Access" User Level

  Scenario: User with unlimited access can see all children
    Given a user "unlimited" with "Access all data" permission
      And a user "limited" with "limited" permission
      And the following children exist in the system:
       | name   | created_by |
       | Andrew | limited    |
       | Peter  | unlimited  |
     When I am logged in as "unlimited"
      And I follow "View All Children"
     Then I should see "Andrew"
      And I should see "Peter"

  Scenario: User with limited access cannot see all children
    Given a user "unlimited" with "Access all data" permission
      And a user "limited" with "limited" permission
      And the following children exist in the system:
       | name   | created_by |
       | Andrew | limited    |
       | Peter  | unlimited  |
     When I am logged in as "limited"
      And I follow "View All Children"
     Then I should see "Andrew"
      And I should not see "Peter"

  Scenario: User with unlimited access should not see the Admin menu
    Given a user "unlimited" with "Access all data" permission
    When I am logged in as "unlimited"
    Then I should not see "Admin"
     And I cannot follow "Admin"

  Scenario: User with limited access should not see the Admin menu
   Given a user "limited" with "limited" permission
    When I am logged in as "limited"
    Then I should not see "Admin"
     And I cannot follow "Admin"

  Scenario: Admins should be able view himself
    Given I am logged in as an admin
    And I follow "Admin"
    And I follow "Manage Users"
     Then I should see "Show"
     Then I should see "Edit"
     Then I should not see "Delete User"
     Then I should see "Back"
     Then I should see "Create an User"

