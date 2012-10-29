@roles
Feature: As an admin, I should be able to edit existing users.

Scenario: When editing a user I cannot edit their user name
  Given a user "mary" with a password "123" 
  And I am logged in as an admin
  And I am on the edit user page for "mary"

  Then the "User name" field should be disabled

Scenario: Check that an admin creates a user record and is able to edit it

  # Create a user
  Given I am logged in as an admin
  And I am on manage users page
  And I follow "Create an User"

  When I fill in "George Harrison" for "Full name"
  And I fill in "george" for "User name"
  And I fill in "password" for "user_password"
  And I fill in "password" for "Re-enter password"
  And I check "field_worker"
  And I fill in "8007778339" for "Phone"
  And I fill in "abcd@unicef.com" for "Email"
  And I fill in "UNICEF" for "Organisation"
  And I fill in "Rescuer" for "Position"
  And I fill in "Amazon" for "Location"
  And I press "Create"

  # View user
  Then I should see "User was successfully created."
  And I should see "George Harrison"
  And I should see "george"
  And I should see "Field Worker"
  And I should see "8007778339"
  And I should see "abcd@unicef.com"
  And I should see "UNICEF"
  And I should see "Rescuer"
  And I should see "Amazon"

  # Editing the user
  When I follow "Edit"
  And I fill in "Julia Roberts" for "Full name"
  And I fill in "pass" for "user_password"
  And I fill in "pass" for "Re-enter password"
  And I check "admin"
  And I fill in "xyz@nyu.com" for "Email"
  And I fill in "NYU" for "Organisation"
  And I fill in "student" for "Position"
  And I fill in "new york" for "Location"
  And I press "Update"

  # Verifying the edited details
  Then I should see "User was successfully updated"
  And I should see "Julia Roberts"
  And I should see "george"
  And I should see "admin"
  And I should see "xyz@nyu.com"
  And I should see "NYU"
  And I should see "student"
  And I should see "new york"

Scenario: Admin should be able to delete another user but not themselves

  Given a user "gui" with a password "123"
  And I am logged in as an admin
  And I am on the manage users page
  Then user "gui" should exist on the page
  Then I should see "Delete User" for "gui"
  And I should not see "Delete User" for "admin"
  When I follow "Delete User"
  Then user "gui" should not exist on the page

Scenario: Should be able to set devices to black listed

  Given a user "tim"
  And devices exist
    | imei | blacklisted | user_name |
    | 123456 | false | tim |
    | 555666 | false | tim |
  And I am logged out
  And I am logged in as an admin
  And I am on the edit user page for "tim"
  And I should see "123456"
  When I check the device with an imei of "123456"
  Then I wait for 10 seconds
  And I press "Update"
  Then I should see "123456 (blacklisted)"

@javascript  
Scenario: Admin should not see "Disable" control or change role control when she is editing her own record
  Given I am logged in as an admin
  And I am on manage users page
  And I follow "Edit"
  And I should not see "Roles" within "form"
  Then I should not see "Disabled"

Scenario: User with Create/Edit Users permission should be able to edit their own general information, but should not be able to edit their devices
  Given a user "jerry" with a password "123" and "Create and Edit Users" permission
  And I am logged out
  And I am logged in as "jerry"
  And I follow "Account"
  And I click text "Edit"
  Then I should not see "IMEI"
  Then the "Organisation" field should be disabled

Scenario: Check that a basic user cannot create a user record
  Given I am logged in as a User with "limited" permission
  Then I should not see "IMEI"
  Then I should not be able to see new user page

 Scenario: Should see "Disable" and change user type controls when trying to create a new user with the logged-in user's username 
  Given I am logged in as an admin
  And I am on new user page
  When I fill in "admin" for "User name"
  When I press "Create"
  And I should see "Disabled"
