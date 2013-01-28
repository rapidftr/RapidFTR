Feature: Can create system users with the permission to synchronise

  Background:
    Given I am logged in as a user with "Users for synchronisation" permission

  Scenario: Add, edit and delete system users
    When I am on system users page
    And I should see "Create a System User"

    When I follow "Create a System User"
    And I fill in "Adrian" for "system_users_name"
    And I fill in "password" for "system_users_password"
    And I click the "Save" button

    Then I should see "Create a System User"
    And I should see "Adrian"

    When I follow "Edit" within "#system-row-Adrian"
    And I fill in "new password" for "system_users_password"
    And I click the "Save" button
    Then I should see "Create a System User"

    When I follow "Delete" within "#system-row-Adrian"
    Then I should not see "Adrian"

