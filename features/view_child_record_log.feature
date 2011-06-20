Feature:

  As an Admin
  I want to ...
  So that changes to the child record are kept for historical purposed and can be viewed

  Scenario: Creates a child record and checks the log

    Given "Harry" is logged in
    And I am on the children listing page
    And I follow "New child"

    When I fill in "Jorge Just" for "Name"
    And I fill in "27" for "Date of Birth / Age"
    And I select "Male" from "Sex"
    And I fill in "Haiti" for "Birthplace"
    And I attach a photo "features/resources/jorge.jpg"
    And the local date/time is "March 19 2010 13:05" and UTC time is "March 19 2010 13:05UTC"
    And I press "Save"
    And I follow "View the change log"

    Then I should see "2010-03-19 13:05:00 +0000 Record created by harry"

  Scenario:  I log in as a different user, upload a new photo and view the record log

    Given the date/time is "July 19 2010 13:05:32"
    And the following children exist in the system:
    | name       | dob_or_age | gender | birthplace |
    | Jorge Just | 27  | Male   | Haiti               |
    And the date/time is "March 01 2010 17:59:33"
    And "Mary" is logged in
    And I am on the children listing page

    When I follow "Edit"
    And I attach a photo "features/resources/jeff.png"
    And I press "Save"
    And I follow "View the change log"

    Then I should see "2010-03-01 17:59:33 +0000 Photo changed from"
    And I should see the thumbnail of "Jorge Just" with timestamp "2010-07-19T130532"
    And I should see the thumbnail of "Jorge Just" with timestamp "2010-03-01T175933"
    And I should see "by mary"

    When I follow photo with timestamp "2010-07-19T130532"

    Then I should see the photo corresponding to "features/resources/jorge.jpg"

    When I am on the children listing page
    And I follow "Jorge Just"
    And I follow "View the change log"

    When I follow photo with timestamp "2010-03-01T175933"

    Then I should see the photo corresponding to "features/resources/jeff.png"

  Scenario:  I log in as a different user, edit and view the record log

    Given the date/time is "July 19 2010 13:05:15"
    And the following children exist in the system:
    | name       | dob_or_age | gender | birthplace |
    | Jorge Just | 27  | Male   | Haiti               |
    And the date/time is "Oct 29 2010 10:12"
    And "Bobby" is logged in
    And I am on the children listing page

    When I follow "Edit"

    Then I fill in "George Harrison" for "Name"
    And I fill in "56" for "Date of Birth / Age"
    And I select "Female" from "Sex"
    And I fill in "Bombay" for "Nationality"
    And I fill in "Zambia" for "Birthplace"
    And the date/time is "Oct 29 2010 14:12:15"
    And I press "Save"

    When I follow "View the change log"

    Then I should see "2010-10-29 14:12:15 +0100 Birthplace changed from Haiti to Zambia by bobby"
    And I should see "2010-10-29 14:12:15 +0100 Nationality initially set to Bombay by bobby"
    And I should see "2010-10-29 14:12:15 +0100 Dob or age changed from 27 to 56 by bobby"
    And I should see "2010-10-29 14:12:15 +0100 Name changed from Jorge Just to George Harrison by bobby"
    And I should see "2010-10-29 14:12:15 +0100 Gender changed from Male to Female by bobby"
    # Order tested at the moment in the show.html.erb_spec.rb view test for histories

  Scenario: Clicking back from the change log

    Given "Harry" is logged in
    And the following children exist in the system:
    | name       | age | age_is | gender | birthplace |
    | Bob | 12  | Exact  | Male   | Spain               |

    When I am on the change log page for "Bob"
    And I follow "Back"

    Then I should be on the child record page for "Bob"

  Scenario:  The change log page displays date-times in my local timezone

    Given the date/time is "July 19 2010 13:05:15UTC"
    And the following children exist in the system:
    | name       | age | age_is | gender | last_known_location |
    | Jorge Just | 27  | Exact  | Male   | Haiti               |
    And the date/time is "Oct 29 2010 10:12UTC"
    And "Bobby" is logged in
    And I am on the children listing page

    When I follow "Edit"

    Then I fill in "George Harrison" for "Name"
    And I attach a photo "features/resources/jorge.jpg"
    And I attach the file "features/resources/sample.mp3" to "Recorded Audio"
    And the date/time is "Oct 29 2010 14:12:15UTC"
    And I press "Save"

    When the user's time zone is "(GMT-11:00) Samoa"
    And I am on the change log page for "George Harrison"

    Then I should see "2010-10-29 03:12:15 -1100 Audio"
    Then I should see "2010-10-29 03:12:15 -1100 Photo"
    And I should see "2010-10-29 03:12:15 -1100 Name changed"
    And I should see "2010-07-19 02:05:15 -1100 Record created"
    # Order tested at the moment in the show.html.erb_spec.rb view test for histories
