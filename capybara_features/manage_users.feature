Feature: Manage Users

#Story: Changing user disabled status from user list page

  @javascript
  @wip
  Scenario: Admins should be able to change user disabled status from index page
    Given a user "homersimpson"
      And user "homersimpson" is disabled
      And I am logged in as an admin
      And I follow "USERS"

     When I uncheck the disabled checkbox for user "homersimpson"
     Then user "homersimpson" should not be disabled

  @wip
  Scenario: User with access to all data should not see the Users menu
    Given a user "field admin" with "Access all data" permission
    When I am logged in as "unlimited"
    Then I should not see "USERS"


  @wip
  Scenario: User with limited access should not see the Users menu
   Given a user "field worker" with "Register Child" permission
    When I am logged in as "field worker"
    Then I should not see "USERS"


  Scenario: Admins should be able view himself
    Given I am logged in as an admin
    And I follow "USERS"

     Then I should see "Show"
     Then I should see "Edit"
     Then I should not see "Delete User"
     Then I should see "Back"
     Then I should see "Create an User"

