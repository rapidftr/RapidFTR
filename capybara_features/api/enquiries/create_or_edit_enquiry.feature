Feature: Creating an enquiry using the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
      | 10002 | false       | jim      |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  Scenario: Create Enquiry

   Given a registration worker "tim" with a password "123"
   And I login as tim with password 123 and imei 10001
   When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "created_at": "2011-03-28 13:23:12UTC",
          "reporter_name" : "bob",
          "reporter_details" : {"location" :"Kampala"},
          "child_name" : "Vini",
          "posted_from" : "Mobile",
          "criteria" : {
            "name" : "Batman"
          }
        }
      }
      """

    Then the JSON at "reporter_name" should be "bob"
    Then the JSON at "child_name" should be "Vini"
    And the JSON at "created_at" should be "2011-03-28 13:23:12UTC"
    And the JSON at "posted_from" should be "Mobile"
    And the JSON at "created_organisation" should be "UNICEF"
    And the JSON at "created_by" should be "tim"
    And the JSON at "_id" should be a string
    And the JSON at "_rev" should be a string
    Then the JSON at "criteria" should be a hash


  Scenario: Create Enquiry with no criteria

    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001
    When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "created_at": "2011-03-28 13:23:12UTC",
          "reporter_name" : "bob",
          "reporter_details" : {"location" :"Kampala"},
          "child_name" : "Vini",
          "posted_from" : "Mobile",
          "criteria" : {
          }
        }
      }
    """
    Then I should receive HTTP 422

    #Exception returned currently is 500, but should be 422
    #Bug fixing in progress
#    @wip
  Scenario: Create Enquiry with malformed criteria

      Given a registration worker "tim" with a password "123"
      And I login as tim with password 123 and imei 10001
      When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "created_at": "2011-03-28 13:23:12UTC",
          "reporter_name" : "bob",
          "reporter_details" : {"location" :"Kampala"},
          "child_name" : "Vini",
          "posted_from" : "Mobile",
          "criteria" : {
             "name"
          }
        }
      }
    """
    Then I should receive HTTP 422

  Scenario: Two users editing the same field, the last made change should be visible

    Given the following enquiries exist in the system:
        | reporter_name | _id | created_at  	    	| posted_at		        | created_by |
        |   bob         | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC| Sanchari   |
    When I send a PUT request to "/api/enquiries/1" with JSON:
          """
      {
        "enquiry": {
          "created_at": "2011-03-28 13:23:12UTC",
          "reporter_name" : "bob",
          "reporter_details" : {"location" :"Somewhere in Kampala"},
          "child_name" : "Vinicius",
          "posted_from" : "Mobile",
          "criteria" : {
            "name" : "Batman"
          }
        }
      }
      """
    Then the JSON at "child_name" should be "Vinicius"
    And then I logout
    When a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001
    When I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "created_at": "2011-03-28 13:23:12UTC",
          "reporter_name" : "bob",
          "reporter_details" : {"location" :"Kampala"},
          "child_name" : "Vinny",
          "posted_from" : "Mobile",
          "criteria" : {
            "name" : "Batman"
          }
        }
      }
      """
    Then the JSON at "child_name" should be "Vinny"

