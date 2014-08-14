Feature: So that admin can see Manage Form Sections Page, customize form section details, Create new forms，Disable and enable forms,
         delete fields from a form section

  Background:
    Given I am logged in as an admin
    And the following form sections exist in the system on the "Children" form:
      | name                  | description                   | unique_id         | order | perm_enabled |visible|editable |
      | Basic Identity        | Basic identity about a child  | basic_identity    | 1     | true         |true   |true     |
      | Family Details        | Details of the child's family | family_details    | 2     | false        |true   |true     |
      | Care Arrangements     |                               | care_arrangements | 3     | false        |true   |true     |
      | Other hidden section  |                               | hidden_section    | 4     | false        |false  |true     |
      | Other visible section |                               | visible_section   | 5     | false        |true   |true     |

    And the following fields exists on "basic_identity":
      | name           | type       | display_name | editable |
      | name           | text_field | Name         | false    |
      | nick_name      | text_field | Nick Name    | true     |
      | second_name    | text_field | Second Name  | true     |
      | characteristic | text_field | Characteristic  | true     |
      | nationality    | text_field | Nationality  | true     |
    And the following fields exists on "family_details":
      | name          | type       | display_name  |
      | another_field | text_field | another field |

  Scenario: Admins should see correct re-ordering links for each section
    Given I follow "FORMS"
    And I follow "Children"
    Then I should see the "Basic Identity" section without an enabled checkbox
    And I should see the "Care Arrangements" section with an enabled checkbox
    And I should see "Family Details" with order of "2"
    And I should see "Care Arrangements" with order of "3"

  Scenario: Admins should be able to edit name and description
    Given I am on the form sections page for "Children"
    And I follow "Family Details"
    Then I should find the form with following attributes:
      | Name |
      | Description |
      | Visible |
    When I fill in "Name" with "Edited Form"
    When I fill in "Description" with "Edited Description"
    And I click the "Save Details" button
    And I am on the form sections page for "Children"
    And I should see the description text "Edited Description" for form section "Edited Form"

  Scenario: Admins should be able to cancel edit and return to the form sections page
    Given I am on the edit form section page for "family_details"
    And the "Cancel" button presents a confirmation message
    When I follow "Cancel"
    Then I should be on the form sections page for "Children"

  Scenario: Admins should not see Visible checkbox for perm_enabled form so that he cannot disable the form
    Given I am on the edit form section page for "basic_identity"
    Then I should not see "Visible checkbox" with id "form_section_visible"

  Scenario: Admins should see Visible checkbox for editable form so that he can enable/disable the form.
    Given I am on the edit form section page for "family_details"
    And I wait until "family_details" is visible
    Then I should see "Visible checkbox" with id "form_section_visible"

  Scenario: name field form section should not be editable
    Given I am on the edit form section page for "basic_identity"
    Then I should not be able to edit "Name" field
    Then I should be able to edit "Nick Name" field

  @javascript
  @wip
  Scenario: Admin should be able to change the order of the fields on edit form section page
    Given I am on the edit form section page for "basic_identity"
    When I demote field "nick_name"
    And I am on the edit form section page for "basic_identity"
    Then I should find the form section with following attributes:
      | Name          |
      | Name          |
      | Nick Name     |
      | Second Name   |
      | Characteristic|
      | Nationality   |

  @run
  Scenario: User creates a new form and it is added to the bottom of the list of forms
    Given I am on the form sections page for "Children"
    When I follow "Create New Form Section"
    And I fill in "form_section_name" with "New Form 1"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"
    And I press "Save Details"
    Then I land in edit page of form New Form 1

    When I am on the form sections page for "Children"
    Then I should see the following form sections in this order:
      | Basic Identity      |
      | Family Details      |
      | Care Arrangements   |
      |Other hidden section |
      |Other visible section|
      | New Form 1          |
    And I should see the description text "I am a new custom form.  Say hello!" for form section "New Form 1"

  Scenario: Disallowing non alphanumeric characters in the name field
    Given I am on the form sections page for "Children"
    When I follow "Create New Form Section"
    And I fill in "form_section_name" with "This is D$dgy"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"
    And I press "Save Details"
    Then I should see "Name must contain only alphanumeric characters and spaces"

  Scenario: Name field cannot be empty
    Given I am on the form sections page for "Children"
    When I follow "Create New Form Section"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"
    And I press "Save Details"
    Then I should see "Name must not be blank"

  Scenario: Cancelling the creation of a form
    Given I am on the form sections page for "Children"
    When I follow "Create New Form Section"
    And I fill in "form_section_name" with "New Form 1"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"
    And I click Cancel
    Then I should be on the form sections page for "Children"
    And I should see the following form sections in this order:
      | Basic Identity       |
      | Family Details       |
      | Care Arrangements    |
      | Other hidden section |
      | Other visible section|

  Scenario: Can create a form section disabled

    Given I am on the form sections page for "Children"
    And I follow "Create New Form Section"
    Then I should see "Visible checkbox" with id "form_section_visible"
    And I fill in "form_section_name" with "New Form 1"
    And I uncheck "Visible"

    When I press "Save Details"

    Then I am on the form sections page for "Children"
    And the form section "New Form 1" should be listed as hidden

  @javascript
  Scenario: Should show selected forms
    Given I am on the form sections page for "Children"
    Then the form section "Other hidden section" should be listed as hidden
    When I select the form section "hidden_section" to toggle visibility
    And I am on new child page
    Then the form section "Other hidden section" should be present

  @javascript
  Scenario: Should hide selected forms
    Given I am on the form sections page for "Children"
    Then the form section "Other visible section" should be listed as visible
    When I select the form section "visible_section" to toggle visibility
    And I am on new child page
    Then the form section "Other visible section" should be hidden

  @javascript
  Scenario: Adding a highlight field to children form
    Given I am on the admin page
    When I follow "Highlight Fields"
    And I follow "Children"
    And I click text "add"
    And I select menu "Basic Identity"
    And I select menu "Nationality"
    Then I should see "Nationality" within "#highlighted-fields"

    When I remove highlight "Nationality"
    Then I should not see "Nationality" within "#highlighted-fields"

  @javascript
  Scenario: Adding a highlight field to enquiry form
    Given the following forms exist in the system:
      | name         |
      | Enquiries    |
      | Children     |
    And the following form sections exist in the system on the "Enquiries" form:
      | name              | unique_id         | editable | order | visible | perm_enabled |
      | Enquiry Criteria  | enquiry_criteria  | false    | 1     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name           | type       | display_name     | editable |
      | criteria       | text_field | Criteria         | false    |
    And I am on the admin page
    When I follow "Highlight Fields"
    And I follow "Enquiries"
    And I click text "add"
    And I select menu "Enquiry Criteria"
    And I select menu "Criteria"
    Then I should see "Criteria" within "#highlighted-fields"

    When I remove highlight "Criteria"
    Then I should not see "Criteria" within "#highlighted-fields"


  @javascript
  Scenario: A hidden highlighted field must not be visible in Child Summary
    And I am on the form sections page for "Children"
    And I follow "Basic Identity"
    And I hide the Nationality field
    And I press "Save"
    And I am on the admin page
    And I follow "Highlight Fields"
    And I follow "Children"
    And I click text "add"
    When I select menu "Basic Identity"
    Then I should not see "Nationality"

  Scenario: Admins should be able to delete a field from a form section
    When I am on the form sections page for "Children"
    And I follow "Basic Identity"
    And I follow "characteristic_Delete"
    Then I should not see "characteristic"
