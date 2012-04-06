Feature: Viewing child records
  
  Scenario: Viewing a child record with audio attached - mp3
    Given I am logged in
    And a child record named "Fred" exists with a audio file with the name "sample.mp3"
    When I am on the child record page for "Fred"
    Then I should see an audio element that can play the audio file named "sample.mp3"
    When I follow "Edit"
    Then I should see an audio element that can play the audio file named "sample.mp3"

  Scenario: Viewing a child record with audio attached - amr
    Given I am logged in
    And a child record named "Barney" exists with a audio file with the name "sample.amr"
    When I am on the child record page for "Barney"
    Then I should not see an audio tag

  Scenario: Date-times should be displayed according to the current user's timezone setting.
    Given I am logged in
    And the date/time is "July 19 2010 13:05:32UTC"
    And the following children exist in the system:
    | name       | age | age_is | gender | last_known_location |
    | Jorge Just | 27  | Exact  | Male   | Haiti               |
    And the date/time is "March 01 2010 17:59:33UTC"
    And the user's time zone is "(GMT-11:00) Samoa"

    When I am on the child record page for "Jorge Just"
    And I follow "Edit"
    And I fill in "28" for "Date of Birth / Age"
    And I press "Save"

    Then I should see "Registered by: zubair and others on 19 July 2010 at 02:05 (SST)"
    And I should see "Last updated: 01 March 2010 at 06:59 (SST)"

	