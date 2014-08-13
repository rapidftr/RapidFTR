Feature: Add standard forms

  @javascript
  Scenario: Adding Children form data
    Given no forms exist in the system
    And I am logged in as a user with "Admin" permission
    And I am on the forms page
    Then I should not see "Children"
    Given I am on the standard form page
    When I check the Basic Identity form section checkbox
    And I press "Save"
    Then I should be on the forms page
    And I should see "Children"
    When I click the "Children" link
    Then I should see "Basic Identity"
    When I click the "Basic Identity" link
    Then I should see "Name"
    And I should see "FTR Status"
    And I should see "Documents carried by the child"

 @javascript
  Scenario: Adding Enquiries form data
    Given no forms exist in the system
    And I am logged in as a user with "Admin" permission
    And I am on the forms page
    Then I should not see "Enquiries"
    Given I am on the standard form page
    When I check the Enquiry Criteria form section checkbox
    And I press "Save"
    Then I should be on the forms page
    And I should see "Enquiries"
    When I click the "Enquiries" link
    Then I should see "Enquiry Criteria"
    When I click the "Enquiry Criteria" link
    Then I should see "Enquirer Name"
    And I should see "Criteria"
