@roles
Feature: As an admin, I should be able to edit existing users.

  Scenario: When editing a user I cannot edit their user name
    Given a user "mary" with a password "123"
    And I am logged in as an admin
    And I am on the edit user page for "mary"

    Then the "User Name" field should be disabled

  Scenario: Check that an admin creates a user record and is able to edit it

    # Create a user
    Given I am logged in as an admin
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
    And I am logged in as an admin
    And I am on the manage users page
    Then user "gui" should exist on the page
    Then I should see "Delete" for "gui"
    And I should not see "Delete" for "admin"
    When I follow "Delete"
    Then user "gui" should not exist on the page

  Scenario: Admin should not see "Disable" control or change role control when she is editing her own record
    Given I am logged in as an admin
    And I am on manage users page
    And I follow "Edit"
    And I should not see "Roles" within "form"
    Then I should not see "Disabled"

  Scenario: Check that a basic user cannot create a user record
    Given I am logged in as a user with "limited" permission
    Then I should not be able to see new user page

  Scenario: Should see "Disable" and change user type controls when trying to create a new user with the logged-in user's username
    Given I am logged in as an admin
    And I am on new user page
    When I fill in "admin" for "User Name"
    When I press "Create"
    And I should see "Disabled"
