Feature:
	As a user I should not be able to add more than 200 characters for a text field or 700 for a text area so that I don't crash the blackberry client
Scenario: Should be restricted to 200 characters in a text field

  Given I am logged in
  And I am on children listing page
  And I follow "New child"
  When I fill in a 201 character long string for "Name" 
  And I press "Save" 
  Then I should be on the new child page
  And I should see "Name cannot be more than 200 characters long"	

Scenario: Should be restricted to 200 characters in a text area
	Given the following field exists on "basic_details":
	| name | type |
	| my_text_area | text_field |
	Given I am logged in
	And I am on children listing page
	And I follow "New child"
	When I fill in a 401 character long string for "Name" 
	And I press "Save" 
	Then I should be on the new child page
	And I should see "Name cannot be more than 200 characters long"

