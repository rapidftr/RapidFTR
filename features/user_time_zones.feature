Feature: As a user, I should be able to choose a time zone to display date-times

  Scenario: To check that the default time zone on a user's home page is GMT
    Given I am logged in
    And I am on the home page
    Then the "Current time zone" dropdown should have "GMT" selected
