Feature: So that an admin/normal user can manage listed children

  Scenario: Admins should have a back link for easy access
    Given I am logged in as an admin
    And I am on the admin page
    When I follow "Manage Children"
    And I follow "Back"
    Then I am on the admin page

  Scenario: Normal users should have a back link for easy access
    Given I am logged in
    And I am on the home page
    When I follow "View Records"
    And I follow "Back"
    Then I am on the home page
