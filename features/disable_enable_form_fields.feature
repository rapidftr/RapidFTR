Feature: disable/enable form fields

  Background:
    Given I am logged in as an admin

  Scenario:
    Given I am on the manage fields page for "family_details"
    When I check "fields_fathers_name"
    And I press "Disable"
    Then I should see the text "Disabled" in the list of fields for "fathers_name"

    