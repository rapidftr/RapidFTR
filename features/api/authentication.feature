@allow-rescue
Feature: Only authorized API clients should be allowed to access the system

  Background:
    Given a user "tim" with a password "123"
    Given devices exist
      | imei  | blacklisted | user_name|
      | 10001 | false       | tim  |
      | 10002 | true        | tim  |

  Scenario: API user sending bad credentials
    When I login as timo with password 1234 and imei 10001
    Then I should receive HTTP 401

  Scenario: API user sending correct credentials
    When I login as tim with password 123 and imei 10001
    Then I should receive HTTP 201

  Scenario: API user blacklisted device
    When I login as tim with password 123 and imei 10002
    Then I should receive HTTP 403

  Scenario: API should timeout the session
    When I login as tim with password 123 and imei 10003
    And I expire my session
    And I send a GET request to "/api/form_sections"
    Then I should receive HTTP 401

  Scenario: API user successful login
    When I login as tim with password 123 and imei 10004
    Then I should receive HTTP 201
