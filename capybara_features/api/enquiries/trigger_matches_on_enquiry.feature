Feature: Check for matches after creating/editing an enquiry on the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
      | 10002 | false       | jim       |
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
          "criteria" : {
             "name" :  "Tom"
          }
        }
      }
    """
    Then the JSON at "potential_matches/0" should be "1"

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
          "criteria" : {
            "name" : "Tom"
          }
        }
      }
      """
    Then the JSON at "potential_matches/0" should be "1"
    When I send a PUT request to "/api/enquiries/1" with JSON:
    """
      {
        "enquiry": {
          "enquirer_name" : "bob",
          "criteria" : {
            "name" : "Tom",
            "location" : "kampala"
          }
        }
      }
      """
    Then the JSON at "potential_matches" should be ["2","1"]
