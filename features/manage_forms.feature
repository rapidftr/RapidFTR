Feature: So that admin can see Manage Forms Page

  Background:
    Given I am logged in as an admin
    And I follow "Admin"
    And I create a new form called "Other details"
    And I follow "Manage Forms"

  Scenario: Admins should see correct re-ordering links for each section
    Then I should see the "basic_identity" section without any ordering links
 		And I should see the "basic_identity" section without an enabled checkbox
		And I should see the "care_arrangements" section with an enabled checkbox
    And I should see "family_details" with order of "2"
    And I should see "care_arrangements" with order of "3"
    And I should see "other_details" with order of "10"
  
  Scenario: Admins should see a back button
    Then I should see "Back"
