
Feature: So that admin can customize fields in a form section

  Background:
    Given the following form sections exist in the system:
      | name           | unique_id      | editable | order | visible | perm_enabled |
      | Basic details  | basic_details  | false    | 1     | true    | true         |
      | Family details | family_details | true     | 2     | true    | false        |
    Given I am logged in as an admin

  @javascript
    @run
  Scenario: Admins should be able to add new text fields
    Given I am on the edit form section page for "family_details"

    When I follow "Add Field"
    When I follow "Text Field"
    And I wait until "Text Field" is visible

    Then I should find the form with following attributes:
      | field_display_name_en |
      | Help text    |
      | Visible      |
    And the "Visible" checkbox should be checked

    When I fill in "field_display_name_en" with "Anything"
    And I fill in "Help text" with "Really anything"
    And I press "Save Details" within "#new_field"
    And I wait until "Fields" is visible

    Then I should see "Anything"
    When I am on children listing page
    And I follow "Register New Child"

    Then I should see "Anything"

  @javascript
  Scenario: Admins should be able to add new date fields
    Given I am on the edit form section page for "family_details"
    And I wait until "family_details" is visible

    When I follow "Add Field"
    And I wait until "Add Field" is visible

    When I follow "Date Field"

    Then I should find the form with following attributes:
      | field_display_name_en |
      | Help text    |
      | Visible      |
    And the "Visible" checkbox should be checked

    When I fill in "field_display_name_en" with "Anything"
    And I fill in "Help text" with "Really anything"
    And I press "Save Details" within "#new_field"

    Then I should see "Anything"

    When I am on children listing page
    And I follow "Register New Child"
    And I follow "Family details"

    Then I should see "Anything"
    When I fill in "Anything" with "17 Nov 2010"
    And I press "Save"
    Then I should see "17 Nov 2010"

  @javascript
  Scenario: Admins should be able to add new radio button
    Given I am on the edit form section page for "family_details"

    When I follow "Add Field"

    When I follow "Radio button"

    Then I should find the form with following attributes:
      | field_display_name_en |
      | Help text    |
      | Visible      |
      | field_option_strings_text_en  |
    And the "Visible" checkbox should be checked

    When I fill in "field_display_name_en" with "Radio button name"
    And I fill in "Help text" with "Something"
    And I fill the following options into "field_option_strings_text_en":
    """
    one
    two
    """
    And I wait until "Save Details" is visible
    And I press "Save Details" within "#field_details_options"

    Then I should see "Radio button name"
    When I am on children listing page
    And I follow "Register New Child"

    Then I should see "Radio button name"

  @wip
  Scenario: Basic Details should have no option to edit it's fields

    Given I am on the form section page

    Then I should not see the "Manage Fields" link for the "basic_details" section

  @javascript
  Scenario: Should not be able to add two fields with the same name in a form section
    Given I am on the form section page
    And I am on the edit form section page for "family_details"

    When I add a new text field with "My field" and "Description"
    And I add a new text field with "My field" and "Description 2"

    Then I should see "Field already exists on this form"

  @wip
  Scenario: Should not be able to add two fields with the same name
    Given the "basic_details" form section has the field "My field" with help text "Some description"
    And I am on the form section page
    And I am on the edit form section page for "family_details"

    When I add a new text field with "My field" and "Description"

    Then I should see "Field already exists on form 'Basic details'"


  # modal dialogue
  @javascript
  @wip

  Scenario: Should provide navigation links
    Given I am on the form section page
    And I am on the edit form section page for "family_details"

    And I follow "Cancel"
    Then I am on the form section page


  @javascript
  Scenario: creating a numeric field
    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"

    When I follow "Numeric Field"
    And I fill in "Help text" with "Help for a numeric field"
    And I wait until "field_display_name_en" is visible
    And I fill in "field_display_name_en" with "My new number field"
    And I press "Save Details" within "#new_field"

    Then I should see "Field successfully added"
    And I wait until "My new number field" is visible
    And I should see "My new number field" in the list of fields

    When I am on children listing page
    And I follow "Register New Child"
    And I follow "Family details"
    And I fill in "My new number field" with "2345"
    And I press "Save"

    Then I should see "My new number field: 2345"

  @javascript
  Scenario: creating a field without giving a name should dehumanize the display name

    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"

    When I follow "Text Field"
    And I fill in "Help text" with "Help for a text field"
    And I wait until "field_display_name_en" is visible
    And I fill in "field_display_name_en" with "My Text field"
    And I press "Save Details" within "#new_field"

    Then I should see "Field successfully added"
    And I should see "My Text field" in the list of fields

  @javascript
  Scenario: creating a radio_button field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"
    And I follow "Radio button"
    And I wait until "field_display_name_en" is visible
    And I fill in "field_display_name_en" with "Radio button name"
    And I fill the following options into "field_option_strings_text_en":
    """
    one
    two
    """
    And I press "Save Details" within "#field_details_options"

    Then I should see "Field successfully added"

    And I should see "Radio button name" in the list of fields

    When I am on the add child page
    And I follow "Family details"

    Then the "Radio button name" radio_button should have the following options:
      | one\n |
      | two |

  @javascript
  Scenario: creating a dropdown field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"
    And I follow "Select drop down"
    And I fill in "field_display_name_en" with "Favourite Toy"
    And I fill the following options into "field_option_strings_text_en":
    """
    Doll
    Teddy bear
    Younger sibling
    """
    And I press "Save Details" within "#field_details_options"

    Then I should see "Field successfully added"

    And I should see "Favourite Toy" in the list of fields

    When I am on the add child page
    And I follow "Family details"

    Then the "Favourite toy" dropdown should have the following options:
      | label           | selected? |
      | (Select...)     | yes       |
      | Doll            | no        |
      | Teddy bear      | no        |
      | Younger sibling | no        |


  #checkbox
  @javascript
  @wip
  Scenario: creating a multiple-checkbox field
    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"
    And I follow "Check boxes"
    And I fill in "field_display_name_en" with "Toys"
    And I fill the following options into "field_option_strings_text_en":
    """
	Action Man
	Barbie
	Lego
	"""

    And I press "Save Details" within "#field_details_options"
    Then I should see "Field successfully added"
    And I should see "Toys" in the list of fields
    When I am on the add child page
    And I follow "Family details"
    And I wait until "Toys" is visible
    Then the "Toys" checkboxes should have the following options:
      | value      | checked? |
      | Action Man | no       |
      | Barbie     | no       |
      | Lego       | no       |
    When I check "Lego" for "Toys"
    And I check "Action Man" for "Toys"
    And I press "Save Details" within "#field_details_options"
    Then I should see "Action Man, Lego"
    When I follow "Edit"
    And I follow "Family details"
    Then the "Toys" checkboxes should have the following options:
      | value      | checked? |
      | Action Man | yes      |
      | Barbie     | no       |
      | Lego       | yes      |

  Scenario: can not create a custom field for forms that aren't editable

    Given I am on the edit form section page for "basic_details"
    Then I should not see "Add Field"
    And I should see "Fields on this form cannot be edited"

 #Scenario doesnt exist any more
  @wip
  Scenario: should be able to go back to edit form section from add custom field page
    Given I am on the edit form section page for "family_details"
    And I follow "Add Field"
    And I follow "Go Back To Edit Forms Page"
    Then I am on edit form section page
