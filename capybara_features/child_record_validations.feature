Feature:
	As a user I should not be able to add more than 200 characters for a text field or 700 for a text area so that I don't crash the blackberry client

Scenario: Should be restricted to 200 characters in a text field

  Given I am logged in as a user with "Register Child" permission
  And I am on children listing page
  And I follow "Register New Child"
  When I fill in a 201 character long string for "Name"
  And I press "Save"
  Then I should see "Name cannot be more than 200 characters long"
  And there should be 0 child records in the database

Scenario: Should be restricted to 400,000 characters in a text area
	Given the following form sections exist in the system:
      | name | unique_id | editable | order |
      | Basic details | basic_details | true | 1 |
	Given the following fields exists on "basic_details":
		| name | type | display_name |
		| my_text_area | textarea | my text area |
  Given I am logged in as a user with "Register Child" permission
	And I am on children listing page
	And I follow "Register New Child"
	When I fill in a 400001 character long string for "my text area"
	And I press "Save"
	Then I should see "my text area cannot be more than 400000 characters long"
  	And there should be 0 child records in the database

Scenario: Should be prevented from saving a record that has no data filled in
  Given I am logged in as a user with "Register Child" permission
	And I am on children listing page
	And I follow "Register New Child"
	And I press "Save"
	Then I should see "Please fill in at least one field or upload a file"
  And there should be 0 child records in the database
