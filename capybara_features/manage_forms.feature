Feature: So that admin can see Manage Form Sections Page

  Background:
    Given I am logged in as an admin
    And I follow "Admin"
    And I follow "Manage Form Sections"

  Scenario: Admins should see correct re-ordering links for each section
    Then I should see the "Basic Identity" section without any ordering links
    And I should see the "Basic Identity" section without an enabled checkbox
    And I should see the "Care Arrangements" section with an enabled checkbox
    And I should see "Family details" with order of "2"
    And I should see "Care Arrangements" with order of "3"

  Scenario: Admins should see a back button
    Then I should see "Back"
