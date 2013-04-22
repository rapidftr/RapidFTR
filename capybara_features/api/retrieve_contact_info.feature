Feature:

  As an API user
  I want to hit a URI that returns me the administration contact information

  Scenario: Only Id and Revision properties are returned for each child record
  	Given the following admin contact info:
  	  | key          | value      |
  	  | name         | John Smith |
  	  | organization | UNICEF     |

    When I send a GET request to "/contact_information/administrator.json"

    Then the JSON should have the following:
      | name | "John Smith" |
      | organization | "UNICEF" |
