Feature: Editing Custom Form Fields
  So that we can edit a text field
  

  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order | enabled |
      | Basic details | basic_details | false | 1 | true |
      | Family details | family_details | true | 2 | true |
    Given the following fields exists on "family_details":
    	| name | type | display_name |
    	| another_field | text_field | another field |

  Scenario: editing a text field
    Given I am logged in as an admin
    And I am on the edit field page for "another_field" on "family_details" form
    Then I should find the form with following attributes:
      | Display name |
      | Help text |
      | Enabled |
    When I fill in "Edited Field" for "Display name"
    When I fill in "false" for "Enabled"
    And I press "Save"
    
    Then I should see "Edited Field"
    Then I should see "Hidden"
    And I should see "another_field" in the list of fields
    
  Scenario: editing text with invalid display name
    Given I am logged in as an admin
    And I am on the edit field page for "another_field" on "family_details" form
    When I fill in "!@#$%$" for "Display Name"
    And I press "Save"
    Then I should see errors

	Scenario: moving a field to another form
		Given I am logged in as an admin
    And I am on the edit field page for "another_field" on "family_details" form
    Then I should find the form with following attributes:
      | Display name |
      | Help text |
      | Enabled |
      | Form |
    When I select "Basic details" from "Form"
		And I press "Save"
		Then I should not see "Edited Field"
		And I am on the edit field page for "another_field" on "basic_details" form 
		
		
    