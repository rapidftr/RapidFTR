Feature: So that admin can customize fields in a form section

  Background:
    Given the following form sections exist in the system:
      | name           | unique_id      | editable | order | enabled | perm_enabled |
      | Basic details  | basic_details  | false    | 1     | true    | true         |
      | Family details | family_details | true     | 2     | true    | false        |
    Given I am logged in as an admin


  Scenario: Admins should be able to add new text fields
    Given I am on the edit form section page for "family_details"

    When I follow "Add Custom Field"

    Then I should find the following links:
      | Text Field       | new field page for "text_field" on "family_details"      |
      | Text Area        | new field page for "textarea" on "family_details"      |
      | Check boxes      | new field page for "check_boxes" on "family_details"      |
      | Select drop down | new field page for "select_box" on "family_details"        |
      | Radio button     | new field page for "radio_button" on "family_details"      |
      | Numeric Field    | new field page for "numeric_field" on "family_details"      |


    When I follow "Text Field"

    Then I should find the form with following attributes:
      | Display name |
      | Help text    |
      | Visible      |
    And the "Visible" checkbox should be checked

    When I fill in "Anything" for "Display name"
    And I fill in "Really anything" for "Help text"
    And I press "Save"

    Then I should see "Anything"
    When I am on children listing page
    And I follow "Register New Child"
    
    Then I should see "Anything"

  Scenario: Admins should be able to add new date fields
    Given I am on the edit form section page for "family_details"

    When I follow "Add Custom Field"

    Then I should find the following links:
      | Date Field | new field page for "date_field" on "family_details" |

    When I follow "Date Field"

    Then I should find the form with following attributes:
      | Display name |
      | Help text    |
      | Visible      |
    And the "Visible" checkbox should be checked

    When I fill in "Anything" for "Display name"
    And I fill in "Really anything" for "Help text"
    And I press "Save"

    Then I should see "Anything"

    When I am on children listing page
    And I follow "Register New Child"

    Then I should see "Anything"
    When I fill in "17 Nov 2010" for "child_anything"
    And I press "Save"
    Then I should see "17 Nov 2010"

  Scenario: Admins should be able to add new radio button
    When I am on the edit form section page for "family_details"

    When I follow "Add Custom Field"

    Then I should find the following links:
      | Radio button | new field page for "radio_button" on "family_details"|

    When I follow "Radio button"

    Then I should find the form with following attributes:
      | Display name |
      | Help text    |
      | Visible      |
      | Options      |
    And the "Visible" checkbox should be checked

    When I fill in "Radio button name" for "Display name"
    And I fill in "Something" for "Help text"
    And I fill the following options into "Options":
    """
    one
    two
    """
    And I press "Save"

    Then I should see "Radio button name"
    When I am on children listing page
    And I follow "Register New child"

    Then I should see "Radio button name"


  Scenario: Basic Details should have no option to edit it's fields

    Given I am on the form section page

    Then I should not see the "Manage Fields" link for the "basic_details" section

  Scenario: Should not be able to add two fields with the same name in a form section
    Given I am on the form section page
    And I am on the edit form section page for "family_details"

    When I add a new text field with "My field" and "Description"
    And I add a new text field with "My field" and "Description 2"

    Then I should see "Field already exists on this form"

  Scenario: Should not be able to add two fields with the same name
    Given the "basic_details" form section has the field "My field" with help text "Some description"
    And I am on the form section page
    And I am on the edit form section page for "family_details"

    When I add a new text field with "My field" and "Description"

    Then I should see "Field already exists on form 'Basic details'"

  Scenario: Should provide navigation links
    Given I am on the form section page
    And I am on the edit form section page for "family_details"

    And I follow "Back To Forms Page"
    Then I am on the form section page


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
    And I fill in "Radio button name" for "Display Name"
    And I fill the following options into "Options":
    """
    one
    two
    """
    When I press "Save"

    Then I should see "Field successfully added"

    And I should see "radio_button_name" in the list of fields

    When I go to the add child page
    And I visit the "Family Details" tab

    Then the "Radio button name" radio_button should have the following options:
      | one |
      | two |

  Scenario: creating a dropdown field

    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Select drop down"
    And I fill in "Favourite Toy" for "Display Name"
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
    And I visit the "Family Details" tab

    Then the "Favourite toy" dropdown should have the following options:
      | label           | selected? |
      | (Select...)     | yes       |
      | Doll            | no        |
      | Teddy bear      | no        |
      | Younger sibling | no        |

  Scenario: creating a multiple-checkbox field
    Given I am on the edit form section page for "family_details"
    And I follow "Add custom field"
    And I follow "Check boxes"
    And I fill in "Toys" for "Display Name"
    And I fill the following options into "Options":
    """
			Action Man
			Barbie
			Lego
			"""
    When I press "Save"
    Then I should see "Field successfully added"
    And I should see "toys" in the list of fields
    When I go to the add child page
    And I visit the "Family Details" tab
    Then the "toys" checkboxes should have the following options:
      | value      | checked? |
      | Action Man | no       |
      | Barbie     | no       |
      | Lego       | no       |
    When I check "Lego" for "toys"
    And I check "Action Man" for "toys"
    And I press "Save"
    Then I should see "Toys: Action Man, Lego"
    When I follow "Edit"
    And I visit the "Family Details" tab
    Then the "toys" checkboxes should have the following options:
      | value      | checked? |
      | Action Man | yes      |
      | Barbie     | no       |
      | Lego       | yes      |

  Scenario: can not create a custom field for forms that aren't editable

    Given I am on the edit form section page for "basic_details"
    Then I should not see "Add Custom Field"
    And I should see "Fields on this form cannot be edited"

  Scenario: should be able to go back to edit form section from add custom field page
    Given I am on the edit form section page for "family_details"
    And I follow "Add Custom Field"
    And I follow "Go Back To Edit Forms Page"
    Then I am on edit form section page
