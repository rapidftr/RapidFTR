Feature: Adding a suggested field to a form section
   Background:
     Given the following suggested fields exist in the system:
        | name | unique_id | description | option_strings | type |
        | A_suggested_field | field_one | This is a good field to use | nil | text_field |
        | Another_suggested_field | field_two | This also is a good field to use | nil | text_field |
        | Field_with_options | field_three| Field with options | ["option1", "option2", "option3"] | select_box | 
     And the following form sections exist in the system:
        | name | unique_id |
        | Basic details | basic_details |
   Scenario: Viewing the suggested fields for a form section when adding a field to a form section
     Given I am logged in as an admin
     And I am on the manage fields page for "basic_details"
     When I follow "Add Custom Field"
     Then I should see the following suggested fields:
        | name | unique_id | description |
        | A_suggested_field | field_one | This is a good field to use |
        | Another_suggested_field | field_two | This also is a good field to use |
   Scenario: Adding a suggested field to a form section
     Given I am logged in as an admin
     And I am on the manage fields page for "basic_details"
     When I follow "Add Custom Field"
     #This is for cucumber only  - scriptless version just submits a form via a link
     And I press "A_suggested_field"
     Then I should see "Field successfully added"
     And I should be on the manage fields page for "basic_details"
     And I should see "A_suggested_field" in the list of fields
     When I follow "Add Custom Field"
     Then I should not see the following suggested fields:
        | name | unique_id | description |
        | A_suggested_field | field_one | This is a good field to use |
   Scenario: Adding a suggested field with options
     Given I am logged in as an admin
     And I am on the manage fields page for "basic_details"
     When I follow "Add Custom Field"
     And I press "Field_with_options"
     Then I should see "Field successfully added"
     When I am on children listing page
     And I follow "New child"
     Then I should see the select named "child[Field_with_options]"
     Then I should see an option "option1" for select "child[Field_with_options]"
        
  


     
        