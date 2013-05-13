
Feature: So that admin can customize form section details

  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order | visible | perm_enabled |
      | Basic details | basic_details | true | 1 | true | true |
      | Family details | family_details | true | 2 | true | false |
    And the following fields exists on "basic_details":
    	| name | type | display_name | editable |
    	| name | text_field | Name | false |
        | nick_name | text_field | Nick Name | true |
        | second_name | text_field | Second Name | true |
    And the following fields exists on "family_details":
    	| name | type | display_name |
    	| another_field | text_field | another field |

    And I am logged in as an admin

  Scenario: Admins should be able to edit name and description
    Given I am on the form section page
    And I follow "Family details"
    Then I should find the form with following attributes:
      | Name |
      | Description |
      | Visible |
    When I fill in "Name" with "Edited Form"
    When I fill in "Description" with "Edited Description"
    And I click the "Save Details" button
    And I am on the form section page
    And I should see the description text "Edited Description" for form section "Edited Form"

  Scenario: Admins should be able to cancel edit and return to the formsections page
    Given I am on the edit form section page for "family_details"
    And the "Cancel" button presents a confirmation message
    When I follow "Cancel"
    Then I should be on the form section page

  Scenario: Admins should not see Visible checkbox for perm_enabled form so that he cannot disable the form
    Given I am on the edit form section page for "basic_details"
    Then I should not see "Visible checkbox" with id "form_section_visible"

  Scenario: Admins should see Visible checkbox for editable form so that he can enable/disable the form.
    Given I am on the edit form section page for "family_details"
    And I wait until "family_details" is visible
    Then I should see "Visible checkbox" with id "form_section_visible"

  #currently not able to drag objects using webdriver
  #currently not able to drag objects using webdriver
  @javascript
  @wip
  Scenario: Admins should not be able to demote the name field by promoting following field
    Given I am on the form section page
    And I follow "Basic details"
#    And I should be able to demote the field "nick_name"
#    And I should not be able to promote the field "nick_name"
    When I demote field "nick_name"
    Then I should not be able to promote the field "second_name"
    And I should be able to promote the field "nick_name"

  Scenario: name field form section should not be editable
    Given I am on the edit form section page for "basic_details"
    Then I should not be able to edit "Name" field
    Then I should be able to edit "Nick Name" field

  #currently not able to drag objects using webdriver
  @javascript
  @wip
  Scenario: Admin should be able to change the order of the fields on edit form section page
    Given I am on the edit form section page for "basic_details"
    And I move field "Second Name" up
    And I click the "Save Order" button
    Then I should find the form section with following attributes:
      | Name          |
      | Name          |
      | Second Name   |
      | Nick Name     |





