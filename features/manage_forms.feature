Feature: So that admin can see Manage Forms Page

  Background:
    Given I am logged in
    And I follow "Admin"
    And I follow "Manage Forms" 

  Scenario: Admins should not be able to reorder fields in non editable form section
    Given I am on the admin page
    When I follow "Manage Forms"
    Then I should see "Basic details"
    Then I should see "Family details"
    Then I should see "Caregiver details"
    