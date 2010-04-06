Feature: So that admin can customize fields in a form section
  Scenario:
    Given I am logged in
    Given I am on choose field type page
    Then I should find the following links:
      | TextField | new_text_field_field |
      | TextArea  | new_text_area_field  |
      | Checkbox  | new_check_box_field  |
      | Select Dropdown | new_select_drop_down_field |
    When I follow "TextField"
    Then I should find the form with following attributes:
      | Name |
      | Helptext |
    