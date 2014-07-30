Feature: As an admin, I should be able to Create Users, Edit and Manage existing users.

#Story: Changing user disabled status from user list page

  Background:
    Given a user "jerry"
    Given I am logged in as an admin

    And I follow "USERS"

  @javascript
  Scenario: Admin disables a user and re-enables a user from the edit page

     When the user "jerry" checkbox is marked as "disabled"
     And I wait for the page to load
     Then user "jerry" should be disabled
     And the user "jerry" should be marked as disabled

     When I follow "Show" within "#user-row-jerry"
     Then I should see "Disabled"

     And I am on the manage users page
     When the user "jerry" checkbox is marked as "enabled"
     And I wait for the page to load
     Then user "jerry" should not be disabled
     And the user "jerry" should be marked as enabled

     When I follow "Show" within "#user-row-jerry"
     Then I should see "Enabled"

  Scenario: Admins should be able view himself

     Then I should see "Show"
     And I should see "Edit"
     And I should not see "Delete" within "#user-row-admin"
     And I should see "Back"
     And I should see "Create User"

  Scenario: On the show User page, the breadcrumb consists of List User link and User Name

    When I follow "Show" within "#user-row-jerry"
    Then I should see "jerry (Edit)"
    And I am on manage users page

  Scenario: On the edit User page, the breadcrumb consists of Edit User link and User Name

    When I follow "Edit" within "#user-row-jerry"
    Then I should see "Users > jerry"
    When I follow "Users"
   Then I am on manage users page

  Scenario: On the create User page, the breadcrumb consists of List Users page

    When I follow "Create User"
    And I follow "Users"
    Then I am on manage users page

  Scenario: User clicks Cancel button and is then on the listing page

     When I follow "Edit" within "#user-row-jerry"
     And I follow "Cancel"
     Then I am on manage users page

   Scenario: User clicks Save button on Edit User page and is then on User listing page

     When I follow "Edit" within "#user-row-jerry"
     Then I fill in "Phone" with "9876543210"
     And I press "Update"
     Then I should see "9876543210"

  Scenario: User should be able to see active users sorted by Full Name (by default) and User Name on User Listing page

    Given a user "henry"
     And a user "homer"
     When user "homer" is disabled
     And I am on manage users page
     Then I should see the following users:
     |name |
     |admin|
     |henry|
     |jerry|
     And I should not see "homer"
     When I select "User Name" from "sort"
     Then I should see the following users:
     |name |
     |admin|
     |henry|
     |jerry|

  @javascript
  Scenario: User should be able to see all users sorted by (Full Name|User name) on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "All" from "filter"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |homer|
      |jerry|
    When I select "All" from "filter"
    And I select "User Name" from "sort"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |homer|
      |jerry|

  Scenario: Admin should be able to see the timestamp under device information
    Given a user "jerry" has logged in from a device
    And I am on manage users page
    When I follow "Show" within "#user-row-jerry"
    Then I should see "2012-12-17 09:53:51 UTC"

  @roles
  Scenario: When editing a user I cannot edit their user name
    Given a user "mary" with a password "123"
    And I am on the edit user page for "mary"
    Then the "User Name" field should be disabled

  @roles
  Scenario: Check that an admin creates a user record and is able to edit it

  # Create a user
    And I am on manage users page
    And I follow "Create User"
    When I fill in the following:
      | Full Name         | George Harrison     |
      | User Name         | george              |
      | Password          | password with space |
      | Re-enter password | password with space |
      | Phone             | 8007778339          |
      | Email             | abcd@unicef.com     |
      | Organisation      | UNICEF              |
      | Position          | Rescuer             |
      | Location          | Amazon              |
    And I check "Field worker"
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
    And I fill in the following:
      | Full Name         | Julia Roberts      |
      | Password          | different password |
      | Re-enter password | different password |
      | Email             | xyz@nyu.com        |
      | Organisation      | NYU                |
      | Position          | student            |
      | Location          | New York           |
    And I check "Admin"
    And I press "Update"

  # Verifying the edited details
    Then I should see "User was successfully updated"
    And I should see "Julia Roberts"
    And I should see "george"
    And I should see "admin"
    And I should see "xyz@nyu.com"
    And I should see "NYU"
    And I should see "student"
    And I should see "New York"

  Scenario: Admin should be able to delete another user but not themselves

    Given a user "gui" with a password "123"
    And I am on the manage users page
    Then user "gui" should exist on the page
    Then I should see "Delete" for "gui"
    And I should not see "Delete" for "admin"
    When I follow "Delete"
    Then user "gui" should not exist on the page

  Scenario: Admin should not see "Disable" control or change role control when she is editing her own record

    And I am on manage users page
    When I follow "Edit"
    Then I should not see "Roles" within "form"
    And I should not see "Disabled"

  Scenario: Check that a basic user cannot create a user record

    And I follow "Logout"
    When I am logged in as a user with "limited" permission
    Then I should not be able to see new user page

  Scenario: Should see "Disable" and change user type controls when trying to create a new user with the logged-in user's username

    And I am on new user page
    When I fill in "User Name" with "admin"
    And I press "Create"
    Then I should see "Disabled"

  @allow-rescue
  Scenario: A user who is disabled mid-session can't continue using that session

    Given a user "george"
    And I follow "Logout"
    And I am logged in as "george"
    And I am on the children listing page
    When user "george" is disabled
    And I follow "Register New Child"
    Then I am on the login page

  # Can create system users with the permission to synchronise

  Scenario: Add, edit and delete system users

    Given I logout as "Admin"
    And I am logged in as a user with "Users for synchronisation" permission
    When I am on system users page
    Then I should see "Create a System User"

    When I follow "Create a System User"
    And I fill in "system_users_name" with "Adrian"
    And I fill in "system_users_password" with "password"
    And I click the "Save" button

    Then I should see "Create a System User"
    And I should see "Adrian"

    When I follow "Edit" within "#system-row-Adrian"
    And I fill in "system_users_password" with "new password"
    And I click the "Save" button
    Then I should see "Create a System User"

    When I follow "Delete" within "#system-row-Adrian"
    Then I should not see "Adrian"

  # Attempting to sync a record as an unverified user

  Scenario: An unverified user should be created on the server

    When I request the creation of the following unverified user:
      | user_name  | full_name   | organisation      | password    |
      | bbob       | Billy Bob   | save the children | 12345       |

    Then an unverified user "bbob" should be created
