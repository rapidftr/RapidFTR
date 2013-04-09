
Feature: Disable and enable forms
  In order to customise the view
  As an admin user
  I want to be able to enable and disable particular forms

  @javascript
  Scenario: Should show selected forms
    Given the following form sections exist in the system:
      | name                  | unique_id         | editable | order | visible |
      | Basic details         | basic_details     | false    | 1     | true    |
      | Caregiver details     | caregiver_details | true     | 2     | true   |
      | Other hidden section  | hidden_section    | true     | 3     | false   |
      | Other visible section | visible_section   | true     | 4     | true   |
    And I am logged in as an admin
    When I am on the form section page

    Then the form section "Other hidden section" should be listed as hidden
    When I select the form section "hidden_section" to toggle visibility
    And I am on new child page

    Then the form section "Other hidden section" should be present

  @javascript
  Scenario: Should hide selected forms
    Given the following form sections exist in the system:
      | name                  | unique_id         | editable | order | visible |
      | Basic details         | basic_details     | false    | 1     | true    |
      | Caregiver details     | caregiver_details | true     | 2     | true    |
      | Other hidden section  | hidden_section    | true     | 3     | false   |
      | Other visible section | visible_section   | true     | 4     | true    |
    And I am logged in as an admin
    When I am on the form section page

    Then the form section "Other visible section" should be listed as visible
    When I select the form section "visible_section" to toggle visibility
    And I am on new child page

    Then the form section "Other visible section" should be hidden

