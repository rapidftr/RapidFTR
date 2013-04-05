
Feature: Disable and enable forms
  In order to customise the view
  As an admin user
  I want to be able to enable and disable particular forms

  @javascript
  Scenario: Should show selected forms
    Given the following form sections exist in the system:
      | name                  | unique_id         | editable | order | visible |
      | Basic details         | basic_details     | false    | 1     | true    |
      | Caregiver details     | caregiver_details | true     | 2     | false   |
      | Other hidden section  | hidden_section    | true     | 3     | false   |
      | Other visible section | visible_section   | true     | 4     | true    |
    And I am logged in as an admin
    When I am on the form section page

    Then the form section "Caregiver details" should be listed as hidden
    And I wait for 5 seconds
    When I select the form section "caregiver_details" to toggle visibility
    And I wait for 5 seconds
    And I show selected form sections

    Then the form section "caregiver_details" should be listed as visible
    And the form section "caregiver_details" should not be selected to toggle visibility

  Scenario: Should hide selected forms
    Given the following form sections exist in the system:
      | name                  | unique_id         | editable | order | visible |
      | Basic details         | basic_details     | false    | 1     | true    |
      | Caregiver details     | caregiver_details | true     | 2     | true    |
      | Other hidden section  | hidden_section    | true     | 3     | false   |
      | Other visible section | visible_section   | true     | 4     | true    |
    And I am logged in as an admin
    When I am on the form section page

    Then the form section "caregiver_details" should be listed as visible

    When I select the form section "caregiver_details" to toggle visibility
    And I hide selected form sections

    Then the form section "caregiver_details" should be listed as hidden
    And the form section "caregiver_details" should not be selected to toggle visibility

