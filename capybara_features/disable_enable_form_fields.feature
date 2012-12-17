Feature: disable/enable form fields

  Background:
    Given I am logged in as an admin

  Scenario: Disable a field
    Given I am on the edit form section page for "basic_identity"
    When I check "fields_characteristics"
    And I press "Hide"
    Then I should see the text "Hidden" in the list of fields for "characteristics"

  Scenario: Enable a field
    Given the "basic_identity" form section has the field "my new field" disabled
    And I am on the edit form section page for "basic_identity"
    When I check "fields_my_new_field"
    And I press "Show"
    Then I should see the text "Visible" in the list of fields for "my_new_field"

  Scenario: Atleast one field should be selected for enabling
    Given the "basic_identity" form section has the field "my new field" disabled
    And I am on the edit form section page for "basic_identity"
    And I press "Show"
    Then I should see "Please select atleast one field to Show" 

  Scenario: Atleast one field should be selected for disabling
    Given the "basic_identity" form section has the field "my new field" disabled
    And I am on the edit form section page for "basic_identity"
    And I press "Hide"
    Then I should see "Please select atleast one field to Hide" 

#@Javascript
#  Scenario: Cancel disable fields
#    Given I am on the edit form section page for "basic_identity"
#    When I check "fields_characteristics"
#    And I press "Disable"
#    And I press "Cancel"
#    Then I should see the text "Enabled" in the list of fields for "characteristics"
#
#  @Javascript
#  Scenario: Cancel enable fields
#    Given the "basic_identity" form section has the field "my new field" disabled
#    Given I am on the edit form section page for "basic_identity"
#    When I check "fields_my_new_field"
#    And I press "Enable"
#    And I press "Cancel"
#    Then I should see the text "Disabled" in the list of fields for "my_new_field"
    