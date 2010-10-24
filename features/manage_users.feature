Feature: So that admin can see Manage Users Page

  Background:
    Given I am logged in as an admin
    And I follow "Admin"
    And I follow "Manage Users" 

  Scenario: Admins should be able view himself
    Given I am on the admin page
    When I follow "Manage Users"
    Then I should see "Show"
    Then I should see "Edit"
    Then I should see "Delete User"

  Scenario: Admins should see a navigational elements
    Then I should see "Back"
    Then I should see "New User"
