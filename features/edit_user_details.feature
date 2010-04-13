Feature: As an admin, I should be able to edit existing users.

Scenario: When editing a user I cannot edit their user_name
  Given a user "mary" with a password "123" 
  And I am logged in
  And I am on the edit user page for "mary"
  Then the "user name" field should be disabled

  Scenario:      To check that an admin creates a user record and is able to edit it.

  # Create an user
    Given I am logged in
    Given I am on manage users page
    And I follow "New user"
    When I fill in "George Harrison" for "Full name"
    And I fill in "george" for "user name"
    And I fill in "password" for "password"
    And I fill in "password" for "Re-enter password"
    And I choose "User"
    And I fill in "abcd@unicef.com" for "email"
    And I fill in "UNICEF" for "organisation"
    And I fill in "Rescuer" for "position"
    And I fill in "Amazon" for "location"
    And I press "Create"

  # Editing the user
    Then I follow "Edit"
    When I fill in "Julia Roberts" for "Full name"
    And I fill in "pass" for "password"
    And I fill in "pass" for "Re-enter password"
    And I choose "Administrator"
    And I fill in "xyz@nyu.com" for "email"
    And I fill in "NYU" for "organisation"
    And I fill in "student" for "position"
    And I fill in "new york" for "location"
    And I press "Update"

  # Verifying the edited details
    Then I should see "User was successfully updated"
    And I should see "Julia Roberts"
    And I should see "george"
    And I should see "Administrator"
    And I should see "xyz@nyu.com"
    And I should see "NYU"
    And I should see "student"
    And I should see "new york"

   # Verifying some of the validations
    When I follow "Edit"
    And I fill in "xyz@nyu" for "email"
    And I fill in "" for "Full name"
    And I press "Update"
    Then I should see "Please enter a valid email address"
    And I should see "Please enter full name of the user"    
    And I should see "Password does not match the confirmation"


    
