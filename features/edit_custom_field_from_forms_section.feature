Feature: So that admin can edit custom fields from a form section

  Scenario: Admins should be able to edit a custom field from a form section

    Given I am logged in as an admin
    And the "family details" form section has the field "my_custom_field" with help text "my custom field"
    And I am on the manage fields page for "family_details"

    When I press "my_custom_field_Edit"

    # Then...?
