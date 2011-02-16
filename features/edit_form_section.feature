Feature: So that admin can customize form section details

  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order | enabled | perm_enabled |
      | Basic details | basic_details | true | 1 | true | true |
      | Family details | family_details | true | 2 | true | false |

  Scenario: Admins should be able to edit name and description
    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"
    Then I should find the form with following attributes:
      | Name |
      | Description |
      | Enabled |
    When I fill in "Edited Form" for "Name"
    When I fill in "Some Description" for "Description"
    And I press "Save"

    Then I am on form section page
    And I should see the description text "Some Description" for form section "family_details"
    And I should see the name "Edited Form" for form section "family_details"

  Scenario: Admins should be able to cancel edit and return to the formsections page
    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"
    Then the "Cancel" button presents a confirmation message
    When I follow "Cancel"
    Then I am on form section page

  Scenario: Admins should not see Enable checkbox for perm_enabled form so that he cannot disable the form
    Given I am logged in as an admin
    And I am on the edit form section page for "basic_details"
    Then I should not see "Enable checkbox" with id "form_section_enabled"

  Scenario: Admins should see Enable checkbox for editable form so that he can enable/disable the form.
    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"
    Then I should see "Enable checkbox" with id "form_section_enabled"

