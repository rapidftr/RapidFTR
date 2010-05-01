Feature: So that admin can customize fields in a form section
  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable |
      | Basic details | basic_details | false |
      | Family details | family_details | true |
    And the "basic details" form section has the field "name" with help text "name"   
    And the "family details" form section has the field "mother" with help text "mother's name" 
    And the "family details" form section has the field "father" with help text "father's name" 
  Scenario: Admins should not be able to reorder fields in non editable form section
    Given I am logged in
    And I am on the manage fields page for "basic_details"
    Then I should not see the "up" arrow for the "name" field
    And I should not see the "down" arrow for the "name" field
    