@allow-rescue
Feature: Only authorized API clients should be allowed to access the system

Background:
 Given there is a User
 And I am logged out

Scenario: Unauthenticated API client gets 401 when attempting to access restricted resource
  Given I am not sending a session token in my request headers
  When I go to the json formatted children listing page
  Then I should be on the json formatted children listing page
  And I should have received a "401 Unauthorized" status code
  And I should see "no session token provided"

Scenario: API client with invalid session token gets a 401 when attempting to access restricted resource
  Given I am sending a session token of "BAD_TOKEN" in my request headers
  When I go to the json formatted children listing page
  Then I should be on the json formatted children listing page
  And I should have received a "401 Unauthorized" status code
  And I should see "invalid session token"

Scenario: Authenticated API client can access restricted resource
  Given I am sending a valid session token in my request headers
  When I go to the json formatted children listing page
  Then I should be on the json formatted children listing page
  And I should have received a "200 OK" status code
