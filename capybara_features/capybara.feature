@javascript
Feature: Test capybara is configured correctly

  Scenario: Log into RapidFTR
    Given a user "rapidftr" with a password "rapidftr"
    Given I am on the login page
    When I fill in "rapidftr" for "user_name"
    And I fill in "rapidftr" for "password"
    And I press "Log in"
