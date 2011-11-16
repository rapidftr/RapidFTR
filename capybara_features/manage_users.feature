Feature: Changing user disabled status from user list page

  @javascript
  Scenario: Admins should be able to change user disabled status from index page
    Given a user "homersimpson"
      And user "homersimpson" is disabled
      And I am logged in as an admin
      And I follow "Admin"
      And I follow "Manage Users"
      #And I am on the manage users page
     When I uncheck the disabled checkbox for user "homersimpson"
     Then user "homersimpson" should not be disabled

