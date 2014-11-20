Feature: Add new user

  Scenario: Adding new user
    Given I am logged in as a user with "Admin" permission

    And I am on new user page
    When I enter the following user details
      | user_full_name    |  user_user_name  | user_password   | user_password_confirmation   | user_phone   | user_organisation   | user_position   | location   |
      | <user_full_name>  | <user_user_name> | <user_password> | <user_password_confirmation> | <user_phone> | <user_organisation> | <user_position> | <location> |
    And I submit the create user form
    Then I should be on manage users page
    And I should see message "There were problems with the following fields"
    And I enter the following user details
      | user_full_name    | user_user_name  | user_password   | user_password_confirmation | user_phone | user_organisation | user_position | user_location  |
      | Handy Enrico      | handy           | P@ssword1       | P@ssword1                  | +1-1234    | Handy Co.         | MD            | Chicago        |
    And I submit the create user form
    Then I should see message "User was successfully created."
    And I should see the user with the following info
      | user_full_name    | user_user_name | user_roles | user_phone | user_organisation | user_position | user_location  |
      | Handy Enrico      | handy          | Admin      | +1-1234    | Handy Co.         | MD            | Chicago        |