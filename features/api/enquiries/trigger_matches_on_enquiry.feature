Feature: Check for matches after creating/editing an enquiry on the API

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
  Scenario: An enquiry should trigger matches
    Given the following children exist in the system:
      | name | _id | created_at             | posted_at              |
      | Tom  | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC |
    When I send a POST request to "/api/enquiries" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "name" :  "Tom",
          "_id" : "1"
        }
      }
    """
    When I am logged in as an admin
    And I am on the enquiry page for "1"
    And I follow "Potential Matches"
    Then I should see "1" children on the page

  @search
  Scenario: Editing an enquiry should also trigger matches

    Given the following children exist in the system:
      | name  | _id | created_at             | posted_at              | birthplace  |
      | Tom   | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Kilimanjaro |
      | Jerry | 2   | 2011-06-22 03:07:51UTC | 2011-06-22 03:07:51UTC | Kampala     |

    And the following enquiries exist in the system:
      | enquirer_name | _id | created_at             | posted_at              | created_by |
      | bob           | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Sanchari   |

    When I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "name" : "Tom"
        }
      }
      """
    And I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "name" : "Tom",
          "location" : "kampala"
        }
      }
      """
    When I am logged in as an admin
    And I am on the enquiry page for "1"
    And I follow "Potential Matches"
    Then I should see "2" children on the page
