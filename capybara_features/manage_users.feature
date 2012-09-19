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

  Scenario: Create new User - Should see options to set User Permission Level
    Given I am logged in as an admin
     When I follow "Admin"
      And I follow "Manage Users"
      And I follow "New User"
     Then I should see "User Permission Level"
      And the "user_permission_limited" radio-button should be checked
      And the "user_permission_unlimited" radio-button should not be checked
     When I choose "user_permission_unlimited"
     Then the "user_permission_unlimited" radio-button should be checked
      And the "user_permission_limited" radio-button should not be checked

  Scenario: Edit existing User - Should see options to set User Permission Level
    Given I am logged in as an admin
      And a user "homersimpson" with "limited" permission
     When I follow "Admin"
      And I follow "Manage Users"
      And I "Edit" user "homersimpson"
     Then I should see "User Permission Level"
      And the "user_permission_limited" radio-button should be checked
      And the "user_permission_unlimited" radio-button should not be checked
     When I choose "user_permission_unlimited"
     Then the "user_permission_unlimited" radio-button should be checked
      And the "user_permission_limited" radio-button should not be checked

  Scenario: User with unlimited access can see all children
    Given a user "unlimited" with "unlimited" permission
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
    Given a user "unlimited" with "unlimited" permission
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
   Given a user "unlimited" with "unlimited" permission
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
     Then I should see "New User"

