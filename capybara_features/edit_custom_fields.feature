
Feature: Editing Custom Form Fields
  So that we can edit a text field
  

  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order | visible |
      | Basic details | basic_details | false | 1 | true |
      | Family details | family_details | true | 2 | true |
    Given the following fields exists on "family_details":
    	| name | type | display_name |
    	| another_field | text_field | another field |

  @javascript
  Scenario: editing a text field
    Given I am logged in as an admin
    And I am on the edit field page for "another_field" on "family_details" form
    Then I should find the form with following attributes:
      | field_display_name_en |
      | Help text |
      | Visible |
    When I fill in "Edited Field" for "field_display_name_en"
    When I uncheck "Visible" within ".field_details_panel"
    And I press "Save Details" within ".field_details_panel"

    Then I should see "Edited Field" in the list of fields and disabled

  @javascript
  Scenario: editing text with invalid display name
    Given I am logged in as an admin
    And I am on the edit field page for "another_field" on "family_details" form
    When I fill in "!@#$%$" for "field_display_name_en"
    And I press "Save Details" within ".field_details_panel"
    Then I should see errors

  @javascript
  Scenario: moving a field to another form
	Given I am logged in as an admin
    And I am on the edit form section page for "family_details"

    When I move field "another_field" to form "Basic details"
    And I am on the edit form section page for "basic_details"
    And I wait for 5 seconds

    Then I should see "another field" in the list of fields