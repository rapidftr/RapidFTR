Feature: As an admin, I should be able to create and view users.

  Scenario: To check that an admin creates a user record and is able to view it
    Given I am logged in as an admin
    And I am on manage users page
    And I follow "New user"

    When I fill in "George Harrison" for "Full name"
    And I fill in "george" for "user name"
    And I fill in "password" for "password"
    And I fill in "password" for "Re-enter password"
    And I choose "User"
    And I fill in "abcd@unicef.com" for "email"
    And I fill in "8007778339" for "phone"
    And I fill in "UNICEF" for "organisation"
    And I fill in "Rescuer" for "position"
    And I fill in "Amazon" for "location"
    And I press "Create"

    Then I should see "User was successfully created."
    And I should see "George Harrison"
    And I should see "george"
    And I should see "User"
    And I should see "8007778339"
    And I should see "abcd@unicef.com"
    And I should see "UNICEF"
    And I should see "Rescuer"
    And I should see "Amazon"

  Scenario:To check for validations on the user record page
    Given I am logged in as an admin
    And I am on new user page
    And I press "Create"

    Then I should see "Please enter full name of the user"
    And I should see "Please enter a valid user name"
    And I should see "Please enter a valid password"
    And I should see "Please choose a user type"

  Scenario: Check that user name and password does not contain spaces

    Given I am logged in as an admin
    And I am on new user page

    When I fill in "George Bush" for "Full Name"
    And I fill in "ge or ge" for "user name"
    And I fill in "pass word" for "password"
    And I fill in "password" for "Re-enter password"
    And I choose "User"
    And I fill in "abcd@unicef.com" for "email"
    And I press "Create"

    Given I am on new user page
    And I fill in "ge or ge" for "user name"
    And I fill in "pass word" for "password"

    When I press "Create"

    Then I should see "Please enter a valid user name"
    And I should see "Please enter a valid password"

  Scenario: Check whether a user name already exists

    Given I am logged in as an admin
    And a user "george" with a password "password"
    And I am on new user page

    When I fill in "George Bush" for "Full Name"
    And I fill in "george" for "user name"
    And I fill in "password" for "password"
    And I fill in "password" for "Re-enter password"
    And I choose "User"
    And I fill in "abcd@unicef.com" for "email"
    And I press "Create"

    Then I should see "User name has already been taken! Please select a new User name"

    When I fill in "bush" for "user name"
    And I press "Create"

    Then I should see "George Bush"

  Scenario: Check the validity of an email address

    Given I am logged in as an admin
    And I am on new user page
    And I fill in "abcdunicef.com" for "email"

    When I press "Create"

    Then I should see "Please enter a valid email address"

    When I fill in "abcd@unicefcom" for "email"

    Then I should see "Please enter a valid email address"

  Scenario: Check that email address is case insensitive

    Given I am logged in as an admin
    And I am on new user page

    When I fill in "George Bush" for "Full Name"
    And I fill in "george1" for "user name"
    And I fill in "password" for "password"
    And I fill in "password" for "Re-enter password"
    And I choose "User"
    And I fill in "Aaa@Bbbb.com" for "email"

    When I press "Create"

    Then I should see "User was successfully created."

  Scenario: Check that a basic user cannot create a user record

    Given I am logged in

    Then I should not be able to see new user page

  Scenario: Should see "Disable" and change user type controls when trying to create a new user with the logged-in user's username 

    Given I am logged in as an admin
    And I am on new user page

    When I fill in "admin" for "user name"

    When I press "Create"

    Then I should see "User type"
    And I should see "Disabled"
