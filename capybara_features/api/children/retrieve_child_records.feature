Feature:

  As an API user
  I want to hit a URI that returns me a list of CouchDB Record Ids and Revision Ids for each child record
  So that an API client can pull down child records one per request

  Background:
    Given devices exist
      | imei  | blacklisted | user_name|
      | 10001 | false       | tim  |

    Given the following children exist in the system:
      | name | _id | created_at             |
      | Tom  | 1   | 2011-06-22 02:07:51UTC |
      | Ben  | 2   | 2011-06-23 02:07:51UTC |

    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  Scenario: Should return JSON for requested child
    When I send a GET request to "/api/children/1"
    Then the JSON should have the following:
      | _id        | "1"                      |
      | name       | "Tom"                    |
      | created_at | "2011-06-22 02:07:51UTC" |

  Scenario: Should return 404 not found if child does not exist
    When I send a GET request to "/api/children/3"
    Then I should receive HTTP 404

  Scenario: Only Id and Revision properties are returned for each child record
    When I send a GET request to "/api/children/ids"
    Then the JSON should be an array
    And the JSON should have 2 entries
    And the JSON at "0" should have 2 keys
    And the JSON at "0/_id" should be "1"
    And the JSON at "0/_rev" should be a string
