Feature: So that an admin can manage listed children

  Background: 
    Given I am logged in as an admin
    
  Scenario: Admins should have a back link for easy access
    Given I am on the admin page

    When I follow "Manage children"
    And I follow "Back"

    Then I am on the admin page
