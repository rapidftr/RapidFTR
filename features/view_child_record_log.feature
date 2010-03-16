Feature:
  So that changes to the child record are kept for historical purposed and can be viewed

	Scenario: Creates a child record and checks the log

	  Given "Harry" is logged in
		And no children exist
		And I am on the children listing page
		And I follow "New child"
		When I fill in "Jorge Just" for "Name"
		And I fill in "27" for "Age"
		And I select "Exact" from "Age is"
		And I choose "Male"
		And I fill in "London" for "Origin"
		And I fill in "Haiti" for "Last known location"
		And I select "1-2 weeks ago" from "Date of separation"
		And I attach the file "features/resources/jorge.jpg" to "photo"
		And the date/time is "July 19 2010 13:05"
		And I press "Finish"

		When I follow "View the change log"
		Then I should see "19/07/2010 13:05 Record created by Harry"

	Scenario:  I log in as a different user, upload a new photo and view the record log

		Given "Mary" is logged in
		And I am on the children listing page

		When I follow "Edit"
		And I attach the file "features/resources/jeff.png" to "photo"
		And the date/time is "Sept 29 2010 17:59"
		And I press "Finish"
		And I follow "View the change log"

		Then I should see "29/09/2010 17:59 Photo changed from view photo link to view photo link by Mary"

		When I follow "from view photo link"
		Then I should see the content type as "image/jpg"
		
		When I am on the children listing page
		And I follow "Jorge Just"
		And I follow "View the change log"

		When I follow "to view photo link"
		Then I should see the content type as "image/png"
