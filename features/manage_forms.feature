Feature: So that admin can see Manage Forms Page

  Background:
    Given I am logged in as an admin
    And I follow "Admin"
    And I follow "Manage Forms" 

  Scenario: Admins should be able view default forms
    Given I am on the admin page
    When I follow "Manage Forms"
    Then I should see "Basic details"
    Then I should see "Family details"
    Then I should see "Caregiver details"

  Scenario: Admins should see a back button
    Then I should see "Back"
