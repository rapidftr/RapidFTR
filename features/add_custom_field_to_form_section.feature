Feature: So that admin can customize fields in a form section
  Background:
     Given the following form sections exist in the system:
        | name | unique_id | editable |
        | Basic details | basic_details | false |
        | Family details | family_details | true |
  Scenario: Admins should be able to add new new text fields
    Given I am logged in
     And I am on the manage fields page for "family_details"
     When I follow "Add Custom Field"
    Then I should find the following links:
      | TextField | new field page for "text_field" |
      | TextArea  | new field page for "textarea"  |
      | Check box  | new field page for "check_box"  |
      | Select drop down | new field page for "select_drop_down" |
    When I follow "TextField"
    Then I should find the form with following attributes:
      | Name |
      | Help text |
      | Enabled |
    And the "Enabled" checkbox should be checked
    When I fill in "Anything" for "name"
    When I fill in "Really anything" for "Help text"
    And I press "Create"
    Then I should see "Anything"
    
  Scenario: Basic Details should have no option to edit it's fields
    Given I am logged in
    And I am on the form section page 
    Then I should not see the "Manage Fields" link for the "basic_details" section
  
      

     