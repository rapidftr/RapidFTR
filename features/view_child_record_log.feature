Feature:
  So that changes to the child record are kept for historical purposed and can be viewed
	Scenario: Creates a child record and checks the log
	  Given "Harry" is logged in
		And I am on the children listing page
		And I follow "New child"
	  When I fill in "Jorge Just" for "Name"
		And I fill in "27" for "Age"
		And I select "Exact" from "Age is"
		And I choose "Male"
		And I fill in "Haiti" for "Last known location"
		And I attach the file "features/resources/jorge.jpg" to "photo"
		And the date/time is "July 19 2010 13:05"
		And I press "Save"
      When I follow "View the change log"
      Then I should see "19/07/2010 13:05 Record created by harry"

	Scenario:  I log in as a different user, upload a new photo and view the record log
      Given the date/time is "July 19 2010 13:05:32"
        And the following children exist in the system:
          | name       | age | age_is | gender | last_known_location |
          | Jorge Just | 27  | Exact  | Male   | Haiti               |
        And the date/time is "Sept 29 2010 17:59:33"
		And "Mary" is logged in
		And I am on the children listing page
      When I follow "Edit"
		And I attach the file "features/resources/jeff.png" to "photo"
		And I press "Save"
		And I follow "View the change log"
        Then I should see "29/09/2010 17:59 Photo changed from"
        And I should see the thumbnail of "Jorge Just" with key "photo-2010-07-19T130532"
        And I should see the thumbnail of "Jorge Just" with key "photo-2010-09-29T175933"
        And I should see "by mary"

		When I follow "photo-2010-07-19T130532"
		Then I should see the photo corresponding to "features/resources/jorge.jpg"

        When I am on the children listing page
        And I follow "Jorge Just"
        And I follow "View the change log"

        When I follow "photo-2010-09-29T175933"
        Then I should see the photo corresponding to "features/resources/jeff.png"

    Scenario:  I log in as a different user, edit and view the record log
      Given the date/time is "July 19 2010 13:05:15"
        And the following children exist in the system:
          | name       | age | age_is | gender | last_known_location |
          | Jorge Just | 27  | Exact  | Male   | Haiti               |
        And the date/time is "Oct 29 2010 10:12"
        And "Bobby" is logged in
        And I am on the children listing page
      When I follow "Edit"
      Then I fill in "George Harrison" for "Name"
        And I fill in "56" for "Age"
        And I select "Approximate" from "Age is"
        And I choose "Female"
        And I fill in "Bombay" for "Origin"
        And I fill in "Zambia" for "Last known location"
        And I select "6 months to 1 year ago" from "Date of separation"
        And the date/time is "Oct 29 2010 10:12:15"
        And I press "Save"
      When I follow "View the change log"
      Then I should see "29/10/2010 10:12 Last known location changed from Haiti to Zambia by bobby"
        And I should see "29/10/2010 10:12 Origin initially set to Bombay by bobby"
        And I should see "29/10/2010 10:12 Age changed from 27 to 56 by bobby"
        And I should see "29/10/2010 10:12 Name changed from Jorge Just to George Harrison by bobby"
        And I should see "29/10/2010 10:12 Date of separation initially set to 6 months to 1 year ago by bobby"
        And I should see "29/10/2010 10:12 Gender changed from Male to Female by bobby"
        And I should see "29/10/2010 10:12 Age is changed from Exact to Approximate"
      # Order tested at the moment in the show.html.erb_spec.rb view test for histories
      
	Scenario: Clicking back from the change log
	  Given "Harry" is logged in
      And the following children exist in the system:
          | name       | age | age_is | gender | last_known_location |
          | Bob | 12  | Exact  | Male   | Spain               |
      When I am on the change log page for "Bob"
      And I follow "Back"
      Then I should be on the child record page for "Bob"

