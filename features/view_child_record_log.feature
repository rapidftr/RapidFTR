Feature:
  So that changes to the child record are kept for historical purposed and can be viewed

Scenario: Creates a child record and checks the log

	Given no children exist
	Given I am on the children listing page
	And I follow "New child"
	When I fill in "Jorge Just" for "Name"
	And I fill in "27" for "Age"
	And I select "Exact" from "Age is"
	And I choose "Male"
	And I fill in "London" for "Origin"
	And I fill in "Haiti" for "Last known location"
	And I select "1-2 weeks ago" from "Date of separation"
	And I attach the file "features/resources/jorge.jpg" to "photo"
	And the date/time is "7/1/2010 11:05"
	And I press "Create"

	When I follow "View the change log"
	Then I should see "7/1/2010 11:05 Record created by fix_me_to_return_session_user_name"






