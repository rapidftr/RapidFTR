@wip
Feature:
  So that changes to the child record are kept for historical purposed and can be viewed
  
	@wip
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
		Then I should see the photo of the child with a "jpg" extension

		When I follow "to view photo link"
		Then I should see the photo of the child with a "png" extension

	@wip
  Scenario:  I log in as a different user, edit and view the record log

    Given I am logged in as "Bobby"

    When I follow "Edit"
    Then I fill in "George Harrison" for "Name"
    And I fill in "56" for "Age"
    And I select "Approximate" from "Age is"
    And I choose "Female"
    And I fill in "Bombay" for "Origin"
    And I fill in "Zambia" for "Last known location"
    And I select "6 months to 1 year ago" from "Date of separation"
    And I press "Update"

    When I follow "View the change log"
    Then I should see "Location changed from Haiti to Zambia by Bobby"
    And I should see the edited date and time stamp
    And I should see "Origin changed from London to Bombay by Bobby"
    And I should see "Age changed from 27 to 56 by Bobby"
    And I should see "Name changed from Jorge Just to George Harrison by Bobby"
    And I should see "Date of separation changed from 1-2 weeks ago to 6 months to 1 year ago by Bobby"
    And I should see "Gender changed from Male to Female by Bobby"
    And I should see "Age is changed from Exact to Approximate"

    # Change log to display ordered list of changes from most recent to older changes --> can this be automated ????
