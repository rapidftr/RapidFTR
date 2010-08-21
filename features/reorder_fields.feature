

Feature: So that admin can customize fields in a form section
  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order |
      | Basic details | basic_details | false | 1 |
      | Family details | family_details | true | 2 |
    And the "basic details" form section has the field "name" with help text "name"   
    And the "family details" form section has the field "mother" with help text "mother's name" 
    And the "family details" form section has the field "father" with help text "father's name" 
  Scenario: Admins should not be able to reorder fields in non editable form section
    Given I am logged in as an admin
    And I am on the manage fields page for "basic_details"
    Then I should not see the "Up" arrow for the "name" field
    And I should not see the "Down" arrow for the "name" field

  Scenario: Admins should be able see up and down arrows
    Given I am logged in as an admin
    And I am on the manage fields page for "family_details"
    Then I should see the "Up" arrow for the "mother" field
    And I should see the "Down" arrow for the "mother" field
    And I should see the "Up" arrow for the "father" field
    And I should see the "Down" arrow for the "father" field

  Scenario: Admins should be able to move a field up
    Given I am logged in as an admin
    And I am on the manage fields page for "family_details"
    And I click the "Up" arrow on "father" field
    Then the "father" field should be above the "mother" field

  Scenario: Admins should be able to move a field down
    Given I am logged in as an admin
    And I am on the manage fields page for "family_details"
    And I click the "Down" arrow on "mother" field
    Then the "father" field should be above the "mother" field


    