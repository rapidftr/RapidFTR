@search
Feature:

  As an Admin
  I want to ...
  So that changes to the child record are kept for historical purposed and can be viewed

  @no_expire
  Scenario: Creates a child record and checks the log

    Given "Harry" logs in with "Register Child" permission
    And I am on the children listing page
    And I follow "Register New Child"

    When I fill in "Name" with "Jorge Just"
    And I fill in "Date of Birth (dd/mm/yyyy)" with "27"
    And I select "Male" from "Sex"
    And I fill in "Birthplace" with "Haiti"
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And the local date/time is "March 19 2010 13:05" and UTC time is "March 19 2010 13:05UTC"
    And I press "Save"
    And I follow "Change Log"

    Then I should see "2010-03-19 13:05:00 UTC Record created by harry"

  @no_expire
  Scenario:  I log in as a different user, upload a new photo and view the record log

    Given the date/time is "July 19 2010 13:05:32"
    And the following children exist in the system:
    | name       | dob_or_age | gender | birthplace |
    | Jorge Just | 27  | Male   | Haiti               |
    And the date/time is "March 01 2010 17:59:33 UTC"
    And "Mary" logs in with "Edit Child,View And Search Child" permissions
    And I am on the children listing page

    When I follow "Edit"
    And I attach a photo "capybara_features/resources/jeff.png"
    And I press "Save"
    And I follow "Change Log"

    Then I should see "2010-03-01 17:59:33 UTC Photo added"
    And I should see the thumbnail of "Jorge Just" with timestamp "2010-03-01T175933"
    And I should see "by mary"

    #These two steps were in the Webrat feature and I have not found a way to replicate in Capybara - Mark
    #When I follow photo with timestamp "2010-03-01T175933"
    #Then I should see the photo corresponding to "capybara_features/resources/jeff.png"

  @no_expire @javascript
  Scenario:  I log in as a different user, edit and view the record log

    Given the date/time is "July 19 2010 13:05:15 UTC"
    And the following children exist in the system:
    | name       | date_of_birth | gender | birthplace |
    | Jorge Just | 12/12/2000  | Male   | Haiti        |
    And the date/time is "Oct 29 2010 10:12 UTC"
    And "Bobby" logs in with "Edit Child,View And Search Child" permissions
    And I am on the children listing page

    When I follow "Edit"

    Then I fill in "Name" with "George Harrison"
    And I fill in "Date of Birth (dd/mm/yyyy)" with "12/12/1999"
    And I select "Female" from "Sex"
    And I fill in "Nationality" with "Bombay"
    And I fill in "Birthplace" with "Zambia"
    And the date/time is "Oct 29 2010 14:12:15 UTC"
    And I press "Save"

    When I follow "Change Log"

    Then I should see "2010-10-29 14:12:15 UTC Birthplace changed from Haiti to Zambia by bobby"
    And I should see "2010-10-29 14:12:15 UTC Nationality initially set to Bombay by bobby"
    And I should see "2010-10-29 14:12:15 UTC Date of birth (dd/mm/yyyy) changed from 12/12/2000 to 12/12/1999 by bobby"
    And I should see "2010-10-29 14:12:15 UTC Name changed from Jorge Just to George Harrison by bobby"
    And I should see "2010-10-29 14:12:15 UTC Sex changed from Male to Female by bobby"
    # Order tested at the moment in the show.html.erb_spec.rb view test for histories

  Scenario: Clicking back from the change log

    Given "Harry" logs in with "Edit Child,View And Search Child" permissions
    And the following children exist in the system:
    | name       | age | age_is | gender | birthplace |
    | Bob | 12  | Exact  | Male   | Spain               |

    When I am on the change log page for "Bob"
    And I follow "Back"

    Then I should be on the child record page for "Bob"

  @no_expire
  Scenario:  The change log page displays date-times in my local timezone

    Given the date/time is "July 19 2010 13:05:15UTC"
    And the following children exist in the system:
    | name       | age | age_is | gender | last_known_location |
    | Jorge Just | 27  | Exact  | Male   | Haiti               |
    And the date/time is "Oct 29 2010 10:12UTC"
    And "Bobby" logs in with "Edit Child,View And Search Child" permissions
    And I am on the children listing page

    When I follow "Edit"

    Then I fill in "Name" with "George Harrison"
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I attach the file "capybara_features/resources/sample.mp3" to "Recorded Audio"
    And the date/time is "Oct 29 2010 14:12:15UTC"
    And I press "Save"

    When the user's time zone is "(GMT-11:00) American Samoa"
    And I am on the change log page for "George Harrison"

    Then I should see "2010-10-29 03:12:15 SST Audio"
    Then I should see "2010-10-29 03:12:15 SST Photo"
    And I should see "2010-10-29 03:12:15 SST Name changed"
    And I should see "2010-07-19 02:05:15 SST Record created"
    # Order tested at the moment in the show.html.erb_spec.rb view test for histories


  @no_expire
  Scenario: As an admin view history of changes made by a user

  As a System admin
  I want to view history of USER ACTION
  So that I can view all the changes particular users are making

    Given "Harry" logs in with "Register Child" permission
    And I am on the children listing page
    And I follow "Register New Child"

    When I fill in "Name" with "Jorge Just"
    And the local date/time is "April 9 2013 13:05" and UTC time is "April 9 2013 13:05UTC"
    And I press "Save"
    And  I logout

    When I am logged in as a user with "Admin" permission
    And  I am on manage users page
    And I follow "Show" within "#user-row-harry"
    When I view User Action History
    Then I should see "2013-04-09 13:05:00 UTC Record created by harry"

  Scenario: As an admin when I view history of user who has no activity, the same should be displayed to me

    Given "Jerry" logs in with "Register Child" permission
    And I am on the children listing page
    And  I logout

    When I am logged in as a user with "Admin" permission
    And  I am on manage users page
    And I follow "Show" within "#user-row-jerry"
    When I view User Action History
    Then I should see "jerry has no activity"
