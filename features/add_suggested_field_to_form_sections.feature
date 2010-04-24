Feature: Adding a suggested field to a form section
   Background:
     Given the following suggested fields exist in the system:
        | name | unique_id | description |
        | A_suggested_field | field_one | This is a good field to use |
        | Another_suggested_field | field_two | This also is a good field to use | 
     And the following form sections exist in the system:
        | name | unique_id |
        | Basic details | basic_details |
   Scenario: Viewing the suggested fields for a form section when adding a field to a form section
     Given I am logged in
     And I am on the manage fields page for "basic_details"
     When I follow "Add Custom Field"
     Then I should see the following suggested fields:
        | name | unique_id | description |
        | A_suggested_field | field_one | This is a good field to use |
        | Another_suggested_field | field_two | This also is a good field to use |
   Scenario: Adding a suggested field to a form section
     Given I am logged in
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
     




     
        