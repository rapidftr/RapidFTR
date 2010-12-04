@allow-rescue
Feature: Only users should be allowed to access the system

  Scenario: web app client with an invalid session token gets redirected to the login page

    Given "Lawrence" is the user
    And I am logged in as "Lawrence"
    And I have an expired session

    When I go to the home page
    And I should see "invalid session token"