Feature: Create new forms
  In order to capture custom information
  I want to allow institutions to create custom forms

  Scenario: User creates a new form
    Given "admin" is logged in
    And I am on form section page
    And I follow "Create form"
    And I fill in "form_section_name" with "New Form 1"
    And I fill in "form_section_description" with "I am a new custom form.  Say hello!"
    And I fill in "form_section_order" with "1"
    When I press "Save Form"
    Then I am on form section page
    Then I should see the "New Form 1" form section link
    And I should see the description text "I am a new custom form.  Say hello!" for form section "new_form_1"
