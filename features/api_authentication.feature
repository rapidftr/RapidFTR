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
    
  Scenario: Authenticated API blackberry is sent kill signal on login if imei is blacklisted
  
    Given a user "tim" with a password "123" 
    And devices exist
      | imei | blacklisted | user_name |
      | 12345 | true | tim |
      | 11111 | false | tim |
    When I login with user tim:123 for device with imei 12345
    Then should be kill response for imei "12345"
    
    When I login with user tim:123 for device with imei 11111
    Then should be successful login
    And I should have received a "201 Created" status code
    
  Scenario: Authenticated API blackberry is sent kill signal on request if imei is blacklisted

    Given I am sending a valid session token in my request headers for device with imei "12345"
    And a user "tim" with a password "123" 
    And devices exist
      | imei | blacklisted | user_name |
      | 12345 | true | tim |
      | 11111 | false | tim |
    When I go to the json formatted children listing page
    Then should be kill response for imei "12345"

  Scenario: Unauthenticated API user sending bad login request should not be logged in
    Given a user "tim" with a password "123"
    And devices exist
      | imei	| blacklisted | user_name|
      | 12345	| false	      |	tim	 |
    When I login with user timo:1234 for device with imei 12345
    Then I should have received a "401 Unauthorized" status code

