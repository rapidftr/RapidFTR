Feature: Create new forms

  In order to capture custom information
  I want to allow institutions to create custom forms

  Background:
    Given I am logged in as an admin
    And the following form sections exist in the system:
      | name              | description                   | unique_id         | order |
      | Basic Details     | Basic details about a child   | basic_details     | 1     |
      | Family Details    | Details of the child's family | family_details    | 2     |
      | Caregiver Details |                               | caregiver_details | 3     |

  Scenario: User creates a new form and it is added to the bottom of the list of forms

    Given I am on form section page
    And I follow "Create form"
    And I fill in "form_section_name" with "New Form 1"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"

    When I press "Save Form"

    Then I am on form section page
    And I should see the "New Form 1" form section link
    And I should see the description text "I am a new custom form.  Say hello!" for form section "new_form_1"
    And "#new_form_1_row" should be "4th" in "#form_sections" table

  Scenario: Disallowing non alphanumeric characters in the name field

    Given I am on form section page
    And I follow "Create form"
    And I fill in "form_section_name" with "This is D£dgy"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"

    When I press "Save Form"

    Then I should see "Name must contain only alphanumeric characters and spaces" within "#errorExplanation"

  Scenario: Name field cannot be empty

    Given I am on form section page
    And I follow "Create form"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"

    When I press "Save Form"

    Then I should see "Name must not be blank" within "#errorExplanation"

  Scenario: Cancelling the creation of a form

    Given I am on form section page
    And I follow "Create form"
    And I fill in "form_section_name" with "New Form 1"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"

    When I follow "Cancel"

    Then I am on form section page
    And I should not see the "New Form 1" form section link

  Scenario: Can create a form section disabled

    Given I am on form section page
    And I follow "Create form"
    And I fill in "form_section_name" with "New Form 1"
    And I uncheck "form_section_enabled"

    When I press "Save Form"

    Then I am on form section page
    And I should see the text "Hidden" in the enabled column for the form section "new_form_1"
