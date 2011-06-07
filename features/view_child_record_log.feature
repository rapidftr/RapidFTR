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
    And the local date/time is "July 19 2010 13:05" and UTC time is "July 19 2010 17:05UTC"
    And I press "Save"
    And I follow "View the change log"

    Then I should see "2010-07-19 17:05:00UTC Record created by harry"

  Scenario:  I log in as a different user, upload a new photo and view the record log

    Given the date/time is "July 19 2010 13:05:32"
    And the following children exist in the system:
    | name       | dob_or_age | gender | birthplace |
    | Jorge Just | 27  | Male   | Haiti               |
    And the local date/time is "Sept 29 2010 17:59:33" and UTC time is "Sept 29 2010 21:59:33UTC"
    And "Mary" is logged in
    And I am on the children listing page

    When I follow "Edit"
    And I attach a photo "features/resources/jeff.png"
    And I press "Save"
    And I follow "View the change log"

    Then I should see "2010-09-29 21:59:33UTC Photo changed from"
    And I should see the thumbnail of "Jorge Just" with timestamp "2010-07-19T130532"
    And I should see the thumbnail of "Jorge Just" with timestamp "2010-09-29T175933"
    And I should see "by mary"

    When I follow photo with timestamp "2010-07-19T130532"

    Then I should see the photo corresponding to "features/resources/jorge.jpg"

    When I am on the children listing page
    And I follow "Jorge Just"
    And I follow "View the change log"

    When I follow photo with timestamp "2010-09-29T175933"

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
    And the local date/time is "Oct 29 2010 10:12:15" and UTC time is "Oct 29 2010 14:12:15UTC"
    And I press "Save"

    When I follow "View the change log"

    Then I should see "2010-10-29 14:12:15UTC Birthplace changed from Haiti to Zambia by bobby"
    And I should see "2010-10-29 14:12:15UTC Nationality initially set to Bombay by bobby"
    And I should see "2010-10-29 14:12:15UTC Dob or age changed from 27 to 56 by bobby"
    And I should see "2010-10-29 14:12:15UTC Name changed from Jorge Just to George Harrison by bobby"
    And I should see "2010-10-29 14:12:15UTC Gender changed from Male to Female by bobby"
    # Order tested at the moment in the show.html.erb_spec.rb view test for histories

  Scenario: Clicking back from the change log

    Given "Harry" is logged in
    And the following children exist in the system:
    | name       | age | age_is | gender | birthplace |
    | Bob | 12  | Exact  | Male   | Spain               |

    When I am on the change log page for "Bob"
    And I follow "Back"

    Then I should be on the child record page for "Bob"
