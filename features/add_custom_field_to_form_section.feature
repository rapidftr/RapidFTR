Feature: So that admin can customize fields in a form section
  Background:
     Given the following form sections exist in the system:
        | name | unique_id | editable | order | enabled |
        | Basic details | basic_details | false | 1 | true |
        | Family details | family_details | true | 2 | true |
  Scenario: Admins should be able to add new new text fields
    Given I am logged in as an admin
     And I am on the manage fields page for "family_details"
     When I follow "Add Custom Field"
    Then I should find the following links:
      | Text Field | new field page for "text_field" |
      | Text Area  | new field page for "textarea"  |
      | Check box  | new field page for "check_box"  |
      | Select drop down | new field page for "select_drop_down" |
    When I follow "Text Field"
    Then I should find the form with following attributes:
      | Name |
      | Help text |
      | Enabled |
    And the "Enabled" checkbox should be checked
    When I fill in "Anything" for "name"
    When I fill in "Really anything" for "Help text"
    And I press "Create"
    Then I should see "Anything"
    When I am on children listing page
    And I follow "New child"
    Then I should see "Anything"
       
  Scenario: Basic Details should have no option to edit it's fields
    Given I am logged in as an admin
    And I am on the form section page 
    Then I should not see the "Manage Fields" link for the "basic_details" section
  
  Scenario: Should not be able to add two fields with the same name in a form section
    Given I am logged in as an admin
    And I am on the form section page 
    And I am on the manage fields page for "family_details"
    When I add a new text field with "My field" and "Description"
    And I add a new text field with "My field" and "Description 2"
    Then I should see "Field already exists for this form section"
    
  
      

     