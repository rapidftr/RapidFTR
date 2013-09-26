Feature: Sync one/all enquiries on the API

  Background:
    Given devices exist
      | imei  | blacklisted | user_name |
      | 10001 | false       | tim       |
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

    @search
  Scenario: Syn all enquiries should display, the urls of all enquiries on the API
    Given the following enquiries exist in the system:
      | enquirer_name | _id | created_at             | posted_at              | created_by |
      | bob           | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Sanchari   |
      | rob           | 2   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Sanchari   |
      | cob           | 3   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Kavitha    |
      | deb           | 4   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Kavitha    |

    When I send a GET request to "/api/enquiries"
    Then the JSON should be:
    """
    [
    {
     "location": "http://example.org:80/api/enquiries/1"
     },
     {
     "location": "http://example.org:80/api/enquiries/2"
     },
     {
     "location": "http://example.org:80/api/enquiries/3"
     },
     {
     "location": "http://example.org:80/api/enquiries/4"
     }
    ]
    """
    When I send a GET request to "/api/enquiries/3"
    Then the JSON at "enquirer_name" should be "cob"

  @search
  Scenario: The url of the enquiries created after a particular time, should be displayed,0 once the appropriate request is sent
    Given the following enquiries exist in the system:
      | enquirer_name   | _id   | created_at             | posted_at              | created_by | match_updated_at       |
      | bob             | 1     | 2013-09-25 02:07:51UTC | 2013-09-25 02:07:51UTC | Sanchari   | 2013-09-25 02:07:51UTC |
      | rob             | 2     | 2013-09-25 02:09:51UTC | 2013-09-25 02:09:51UTC | Sanchari   | 2013-09-25 02:07:51UTC |
      | dobby           | 3     | 2011-06-22 02:09:51UTC | 2011-06-22 02:09:51UTC | Sanchari   | 2011-09-25 02:07:51UTC |
    When I send a GET request to "/api/enquiries?updated_after=2013-09-24"
    Then the JSON should be:
    """
    [
    {
     "location": "http://example.org:80/api/enquiries/1"
     },
     {
     "location": "http://example.org:80/api/enquiries/2"
     }
     ]
    """


