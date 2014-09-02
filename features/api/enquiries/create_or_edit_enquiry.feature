Feature: Creating an enquiry using the API

  Background:

    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
      | 10002 | false       | jim       |
    And the following forms exist in the system:
      | name      |
      | Enquiries |
      | Children  |
    And the following form sections exist in the system on the "Enquiries" form:
      | name          | unique_id     | editable | order | visible | perm_enabled |
      | Basic details | basic_details | false    | 1     | true    | true         |
    And the following fields exists on "basic_details":
      | name           | type       | display_name   | editable | matchable |
      | name           | text_field | Name           | false    | true       |
      | location       | text_field | Location       | true     | true       |
      | enquirer_name  | text_field | Enquirer Name  | true     | true       |
      | characteristic | text_field | Characteristic | true     | false      |
      | nationality    | text_field | Nationality    | true     | false      |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  @search
  Scenario: Create Enquiry

    When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "name" : "Batman",
          "location" : "Kampala"
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
          "parent_name" : "bob"
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
          "name" : "Batman"
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
          "name" : "Batman"
        }
      }
      """
    Then the JSON at "enquirer_name" should be "Bob the builder"

