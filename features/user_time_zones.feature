Feature: As a user, I should be able to choose a time zone to display date-times

  Scenario: To check that the default time zone on a user's home page is UTC
    Given I am logged in
    And I am on the home page
    Then the "Current time zone" dropdown should have "UTC" selected

  Scenario: To check that the user can select a different time zone for the display of date-times
    Given I am logged in
    And I am on the home page
    When I select "(GMT-11:00) American Samoa" from "Current time zone"
    And I press "Save"
    Then I should be on the home page
    And I should see "The change was successfully updated."
    And the "Current time zone" dropdown should have "American Samoa" selected
