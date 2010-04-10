Feature: Adding a suggested field to a form section

   Scenario: Viewing the suggested fields for a form section when adding a field to a form section
     Given the following suggested fields exist in the system:
        | name | unique_id | description |
        | A suggested field | field_one | This is a good field to use |
        | Another suggested field | field_two | This also is a good field to use |
     And the following form sections exist in the system:
        | name | unique_id |
        | Basic details | basic_details |
     And I am logged in
     And I am on the manage fields page for "basic_details"
     When I follow "Add Custom Field"
     Then I should see the following suggested fields:
        | name | unique_id | description |
        | A suggested field | field_one | This is a good field to use |
        | Another suggested field | field_two | This also is a good field to use |
     
        