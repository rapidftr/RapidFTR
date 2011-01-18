Feature: disable/enable form fields

  Background:
    Given I am logged in as an admin

  Scenario: Disable a field
    Given I am on the edit form section page for "family_details"
    When I check "fields_fathers_name"
    And I press "Disable"
    Then I should see the text "Disabled" in the list of fields for "fathers_name"

  Scenario: Enable a field
    Given the "family_details" form section has the field "my new field" disabled
    And I am on the edit form section page for "family_details"
    When I check "fields_my_new_field"
    And I press "Enable"
    Then I should see the text "Enabled" in the list of fields for "my_new_field"

  Scenario: Atleast one field should be selected for enabling
    Given the "family_details" form section has the field "my new field" disabled
    And I am on the edit form section page for "family_details"
    And I press "Enable"
    Then I should see "Please select atleast one field to Enable" 

  Scenario: Atleast one field should be selected for disabling
    Given the "family_details" form section has the field "my new field" disabled
    And I am on the edit form section page for "family_details"
    And I press "Disable"
    Then I should see "Please select atleast one field to Disable" 

#@Javascript
#  Scenario: Cancel disable fields
#    Given I am on the edit form section page for "family_details"
#    When I check "fields_fathers_name"
#    And I press "Disable"
#    And I press "Cancel"
#    Then I should see the text "Enabled" in the list of fields for "fathers_name"
#
#  @Javascript
#  Scenario: Cancel enable fields
#    Given the "family_details" form section has the field "my new field" disabled
#    Given I am on the edit form section page for "family_details"
#    When I check "fields_my_new_field"
#    And I press "Enable"
#    And I press "Cancel"
#    Then I should see the text "Disabled" in the list of fields for "my_new_field"
    