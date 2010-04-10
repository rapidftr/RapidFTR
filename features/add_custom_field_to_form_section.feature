Feature: So that admin can customize fields in a form section
  Scenario:
    Given I am logged in
    Given I am on choose field type page
    Then I should find the following links:
      | TextField | new field page for "text_field" |
      | TextArea  | new field page for "textarea"  |
      | Check box  | new field page for "check_box"  |
      | Select drop down | new field page for "select_drop_down" |
    When I follow "TextField"
    Then I should find the form with following attributes:
      | Name |
      | Help text |

     