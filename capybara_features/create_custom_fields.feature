Feature: Creating Custom Form Fields

  So that we can add a numeric field to a formsection
  
  Background:
		Given the following form sections exist in the system:
		  | name | unique_id | editable | order | enabled | perm_enabled |
		  | Basic details | basic_details | false | 1 | true | true |
		  | Family details | family_details | true | 2 | true | false |
	  Given I am logged in as an admin

  Scenario: creating a numeric field
    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"

    When I follow "Numeric Field"
    And I fill in "Help for a numeric field" for "Help text"
    And I fill in "My new number field" for "Display name"
    And I press "Save"

    Then I should see "Field successfully added"
    And I should see "my_new_number_field" in the list of fields

    When I am on children listing page
    And I follow "Register New Child"
    And I fill in "2345" for "My new number field"
    And I press "Save"

    Then I should see "My new number field: 2345"

  Scenario: creating a field without giving a name should dehumanize the display name

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"

    When I follow "Text Field"
    And I fill in "Help for a text field" for "Help text"
    And I fill in "My Text field" for "Display name"
    And I press "Save"

    Then I should see "Field successfully added"
    And I should see "my_text_field" in the list of fields

  Scenario: creating a radio_button field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Radio button"
    And I fill in "Radio button name" for "Display name"
    And I fill the following options into "Options":
      """
      one
      two
      """
    When I press "Save"

    Then I should see "Field successfully added"
    
    And I should see "radio_button_name" in the list of fields
    
    When I go to the add child page
    And I visit the "Family details" tab

    Then the "Radio button name" radio_button should have the following options:
      | one |
      | two |            
      
  Scenario: creating a dropdown field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Select drop down"
    And I fill in "Favourite Toy" for "Display name"
    And I fill the following options into "Options":
      """
      Doll
      Teddy bear
      Younger sibling
      """
    When I press "Save"

    Then I should see "Field successfully added"

    And I should see "favourite_toy" in the list of fields
    
    When I go to the add child page
    And I visit the "Family details" tab

    Then the "Favourite Toy" dropdown should have the following options:
      | label           |  selected? |
      | (Select...)     |  yes       |
      | Doll            |  no        |
      | Teddy bear      |  no        |
      | Younger sibling |  no        |

  Scenario: can not create a custom field for forms that aren't editable
	
	Given I am on the edit form section page for "basic_details"
	Then I should not see "Add Custom Field"
	And I should see "Fields on this form cannot be edited"
