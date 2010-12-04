Feature: Creating Custom Form Fields

  So that we can add a numeric field to a formsection
  
  Background:
    Given I am logged in as an admin

  Scenario: creating a numeric field
    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"

    When I follow "Numeric Field"
    And I fill in "Help for a numeric field" for "Help text"
    And I fill in "My new number field" for "Display name"
    And I press "Create"

    Then I should see "Field successfully added"
    And I should see "my_new_number_field" in the list of fields

    When I am on children listing page
    And I follow "New child"
    And I fill in "2345" for "My new number field"
    And I press "Save"

    Then I should see "My new number field: 2345"

  Scenario: creating a field without giving a name should dehumanize the display name

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"

    When I follow "Text Field"
    And I fill in "Help for a text field" for "Help text"
    And I fill in "My Text field" for "Display name"
    And I press "Create"

    Then I should see "Field successfully added"
    And I should see "my_text_field" in the list of fields

  Scenario: creating a dropdown field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Select drop down"
    And I fill in "My Dropdown Test" for "Display Name"
    And I fill in options for "Option strings"

    When I press "Create"

    Then I should see "Field successfully added"

    And I should see "my_dropdown_test" in the list of fields

  Scenario: creating a dropdown field that allows blank default option

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Select drop down"
    And I fill in "My Blank Dropdown Test" for "Display Name"
    And I fill in options for "Option strings"
    And I check "Allow blank default"

    When I press "Create"

    Then I should see "Field successfully added"
    And I should see "my_blank_dropdown_test" in the list of fields
    
    When I go to the new child page
    Then the "child[my_blank_dropdown_test]" dropdown should default to ""

  Scenario: can not create a custom field for forms that aren't editable
	
	Given I am on the edit form section page for "basic_details"
	Then I should not see "Add Custom Field"
	And I should see "This form cannot be edited"