Feature: Creating an enquiry using the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
      | 10002 | false       | jim       |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  @search
  Scenario: Create Enquiry

    When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "criteria" : {
            "name" : "Batman",
            "location" : "Kampala"
          }
        }
      }
      """

    Then I should receive HTTP 201
    Then the JSON at "enquirer_name" should be "bob"
    Then the JSON should have "criteria/name"
    Then the JSON should have "criteria/location"


  @search
  Scenario: Create Enquiry with no criteria

    When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "criteria" : {
          }
        }
      }
    """
    Then I should receive HTTP 422

  @search
  Scenario: Two users editing the same field, the last made change should be visible

    Given the following enquiries exist in the system:
      | enquirer_name | _id | created_at             | posted_at              | created_by |
      | bob           | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Sanchari   |
    When I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bobby",
          "criteria" : {
            "name" : "Batman"
          }
        }
      }
      """
    Then the JSON at "enquirer_name" should be "bobby"
    And then I logout
    When a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001
    When I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "Bob the builder",
          "criteria" : {
            "name" : "Batman"
          }
        }
      }
      """
    Then the JSON at "enquirer_name" should be "Bob the builder"

