Feature: So that admin can customize fields in a form section
  Scenario:
    Given I am logged in
    Given I am on choose field type page
    Then I should find the following links:
      | TextField | text_field |
      | TextArea  | text_area  |
      | Checkbox  | check_box  |
      | Select Dropdown | select_drop_down |
    When I follow "TextField"
    Then I should find the form with following attributes:
      | Name |
      | Helptext |
    