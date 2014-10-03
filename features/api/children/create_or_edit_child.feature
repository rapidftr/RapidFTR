Feature: Creating or Editing a child using the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name|
      | 10001 | false       | tim  |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  Scenario: Create Child using API
    When I send a POST request to "/api/children" with JSON:
      """
      {
        "child": {
          "created_at": "2011-03-28 13:23:12UTC",
          "name" : "bob",
          "posted_from" : "Mobile"
        }
      }
      """

    Then the JSON at "name" should be "bob"
    And the JSON at "created_at" should be "2011-03-28 13:23:12UTC"
    And the JSON at "posted_from" should be "Mobile"
    And the JSON at "created_organisation" should be "UNICEF"
    And the JSON at "created_by" should be "tim"
    And the JSON at "created_by_full_name" should be "tim"
    And the JSON at "_id" should be a string
    And the JSON at "_rev" should be a string
    And the JSON at "short_id" should be a string
    And the JSON at "photo_keys" should be an array
    And the JSON at "current_photo_key" should be a string

  Scenario: Edit Child using API
    Given the following children exist in the system:
      | name | _id | created_at  	    	| posted_at		|
      | Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|

    When I send a PUT request to "/api/children/1" with JSON:
      """
      {
        "child" : {
          "name" : "Jorge"
        }
      }
      """
    Then the JSON at "name" should be "Jorge"

    And I send a GET request to "/api/children/1"
    Then the JSON at "name" should be "Jorge"

  Scenario: Edit Child using API

    Given a senior official "richi" with a password "123"
    And I login as richi with password 123 and imei 10001
    And the following children exist in the system:
      | name | _id | created_at  	    	| posted_at		|
      | Raju  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|

    When I send a GET request to "/api/children"
    Then I should receive HTTP 403
