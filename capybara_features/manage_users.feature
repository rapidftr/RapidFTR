Feature:As an admin, I should be able to Create Users,Edit and Manage existing users .

#Story: Changing user disabled status from user list page

  Background:
    Given a user "jerry"
    Given I am logged in as an admin

    And I follow "USERS"

  @javascript
  Scenario: Admin disables a user and re-enables a user from the edit page

     When the user "jerry" checkbox is marked as "disabled"
     Then user "jerry" should be disabled
     And the user "jerry" should be marked as disabled

     When I follow "Show" within "#user-row-jerry"
     Then I should see "Disabled"

     And I am on the manage users page
     When the user "jerry" checkbox is marked as "enabled"
     Then user "jerry" should not be disabled
     And the user "jerry" should be marked as enabled

     When I follow "Show" within "#user-row-jerry"
     Then I should see "Enabled"

    Scenario: Admins should be able view himself
     Then I should see "Show"
     Then I should see "Edit"
     Then I should not see "Delete" within "#user-row-admin"
     Then I should see "Back"
     Then I should see "Create User"

  Scenario: On the show User page, the breadcrumb consists of List User link and User Name
    When I follow "Show" within "#user-row-jerry"
    Then I should see "jerry (Edit)"
    And I am on manage users page

  Scenario: On the edit User page, the breadcrumb consists of Edit User link and User Name
    When I follow "Edit" within "#user-row-jerry"
    Then I should see "Users > jerry"
    Then I follow "Users"
   And I am on manage users page

  Scenario: On the create User page, the breadcrumb consists of List Users page
    Then I follow "Create User"
    Then I follow "Users"
    And I am on manage users page

  Scenario: User clicks Cancel button and is then on the listing page
     When I follow "Edit" within "#user-row-jerry"
     Then I follow "Cancel"
     And I am on manage users page

   Scenario: User clicks Save button on Edit User page and is then on User listing page
     When I follow "Edit" within "#user-row-jerry"
     Then I fill in "9876543210" for "Phone"
     And I press "Update"
     Then I should see "9876543210"

  Scenario: User should be able to see active users sorted by Full Name by default on User Listing page
     Given a user "henry"
     And a user "homer"
     And user "homer" is disabled
     And I am on manage users page
     Then I should see the following users:
     |name |
     |admin|
     |henry|
     |jerry|
     And I should not see "homer"

  Scenario: User should be able to see active users sorted by User Name on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "User Name" from "sort"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |jerry|
    And I should not see "homer"

  @javascript
  Scenario: User should be able to see all users sorted by Full Name on User Listing page
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

  @javascript
  Scenario: User should be able to see all users sorted by User Name on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "All" from "filter"
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
    And I follow "Show" within "#user-row-jerry"
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
      | User Name         | george             |
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
    And I follow "Edit"
    And I should not see "Roles" within "form"
    Then I should not see "Disabled"

  Scenario: Check that a basic user cannot create a user record
    And I follow "Logout"
    When I am logged in as a user with "limited" permission
    Then I should not be able to see new user page

  Scenario: Should see "Disable" and change user type controls when trying to create a new user with the logged-in user's username
    And I am on new user page
    When I fill in "admin" for "User Name"
    When I press "Create"
    And I should see "Disabled"

    @allow-rescue
    Scenario: A user who is disabled mid-session can't continue using that session

    Given a user "george"
    And I follow "Logout"
    And I am logged in as "george"
    And I am on the children listing page
    When user "george" is disabled
    And I follow "Register New Child"
    Then I am on the login page
