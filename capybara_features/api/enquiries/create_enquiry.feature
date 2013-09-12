Feature: Creating an enquiry using the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  Scenario: Create Enquiry

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
