Feature: As an admin, I should be able to edit existing users.

Scenario: When editing a user I cannot edit their user name
  Given a user "mary" with a password "123" 
  And I am logged in as an admin
  And I am on the edit user page for "mary"

  Then the "user name" field should be disabled
  
Scenario: Check that an admin creates a user record and is able to edit it

  # Create an user
  Given I am logged in as an admin
  And I am on manage users page
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
  
Scenario: Should be able to set devices to black listed

  Given a user "tim" with a password "123" 
  And devices exist
    | imei | blacklisted | user_name |
    | 123456 | false | tim |
    | 555666 | false | tim |
  And I am logged in as an admin
  And I am on the edit user page for "tim"
  And I should see "123456"
  When I check the device with an imei of "123456"
  And I press "Update"
  Then I should see "123456 (blacklisted)"

Scenario: Admin should not see "Disable" control or change user type control when she is editing her own record
  Given I am logged in as an admin
  And I am on manage users page
  And I follow "Edit"
  And I should not see "User type"
  Then I should not see "Disabled"

Scenario: User should be able to edit their own general information, but should not be able to edit their devices
Given "mary" is logged in
  And I follow "Account"
  Then I should not see "IMEI"
  Then the "Organisation" field should be disabled


Scenario: Password field should not be blank if re-enter password field is filled in and vice versa
  # Create an user
  Given I am logged in as an admin
  And I am on manage users page
  And I follow "New user"

  When I fill in "John Doe" for "Full name"
  And I fill in "johndoe1" for "user name"
  And I fill in "password" for "password"
  And I fill in "password" for "Re-enter password"
  And I choose "User"
  And I fill in "abcde@unicef.com" for "email"
  And I fill in "UNICEF" for "organisation"
  And I fill in "Rescuer" for "position"
  And I fill in "Amazon" for "location"
  And I press "Create"

  # Editing the user with re-enter password but no password
  Then I follow "Edit"
  And I fill in "pass" for "Re-enter password"
  And I press "Update"
  Then I should see "Password does not match the confirmation"

  #Editing the user with password but no re-enter password
  When I am on the edit user page for "johndoe1"
  Then I fill in "pass" for "password"
  And I press "Update"
  Then I should see "Password does not match the confirmation"