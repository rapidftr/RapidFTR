Feature: So that admin can customize form section details
  Background:
    Given the following form sections exist in the system:
      | name | unique_id | editable | order | enabled |
      | Basic details | basic_details | false | 1 | true |
      | Family details | family_details | true | 2 | true |
        
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


  Scenario: Admins should not disable non editable form
    Given I am logged in as an admin
    And I am on the edit form section page for "family_details"
    Then I should find the form with following attributes:
      | Name |
      | Description |
