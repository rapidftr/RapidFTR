Feature: So that admin can customize fields in a form section

  Background:

    Given the following form sections exist in the system:
      | name           | unique_id      | editable | order |
      | Basic details  | basic_details  | false    | 1     |
      | Family details | family_details | true     | 2     |
    And the "basic details" form section has the field "name" with help text "name"
    And the "family details" form section has the field "first" with help text "first field"
    And the "family details" form section has the field "mother" with help text "mother's name"
    And the "family details" form section has the field "father" with help text "father's name"
    And the "family details" form section has the field "last" with help text "last field"

  Scenario: Admins should not be able to reorder fields in non editable form section

    Given I am logged in as an admin
    And I am on the edit form section page for "basic_details"

    Then I should not see the "Up" arrow for the "name" field
    And I should not see the "Down" arrow for the "name" field

  Scenario: Admins should be able see up and down arrows

    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"

    Then I should see the "Up" arrow for the "mother" field
    And I should see the "Down" arrow for the "mother" field
    And I should see the "Up" arrow for the "father" field
    And I should see the "Down" arrow for the "father" field

  @wip
  Scenario: Reordering fields and saving should change the order number

    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"

    When I click the "Up" arrow on "mother" field
    When I click the "Save Order" button

    Then I should be able to see "Order is successfully saved."
