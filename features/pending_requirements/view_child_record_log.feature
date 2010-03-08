@wip
Feature:
  So that changes to the child record are kept for historical purposed and can be viewed
   @wip
Scenario:  The user logs in, creates a child record and checks the log

       Given no users exist
       Given no children exist

       Given I am logged in as "Harry"

        And I follow "New child"
        When I fill in "Jorge Just" for "Name"
        And I fill in "27" for "Age"
        And I select "Exact" from "Age is"
        And I choose "Male"
        And I fill in "London" for "Origin"
        And I fill in "Haiti" for "Last known location"
        And I select "1-2 weeks ago" from "Date of separation"
        And I attach the file "features/resources/jorge.jpg" to "photo"
        And I press "Create"

        When I follow "View the change log"
        Then I should see "Record created by Harry"
                  And I should see the created date and time stamp
        And I follow "logout"


  Scenario:  I log in as a different user, edit and view the record log

    Given I am logged in as "Mary"

    When I follow "Edit"
    Then I fill in "George Harrison" for "Name"
    And I fill in "56" for "Age"
    And I select "Approximate" from "Age is"
    And I choose "Female"
    And I fill in "Bombay" for "Origin"
    And I fill in "Zambia" for "Last known location"
    And I select "6 months to 1 year ago" from "Date of separation"
    And I attach the file "features/resources/jeff.png" to "photo"
    And I press "Update"

    When I follow "View the change log"
    Then I should see "Location changed from Haiti to Zambia by Mary"
             And I should see the edited date and time stamp
    And I should see "Origin changed from London to Bombay by Mary"
    And I should see "Age changed from 27 to 56 by Mary"
    And I should see "Name changed from Jorge Just to George Harrison by Mary"
    And I should see "Date of separation changed from 1-2 weeks ago to 6 months to 1 year ago by Mary"
    And I should see "Gender changed from Male to Female by Mary"
    And I should see "Age is changed from Exact to Approximate"
    And I should see "Photo changed from view photo link to view photo link by Mary"

    When I follow "from view photo link"
    Then I should see the photo of the child with a "jpg" extension

    When I follow "to view photo link"
    Then I should see the photo of the child with a "png" extension



    # Change log to display ordered list of changes from most recent to older changes --> can this be automated ????






