Feature:

  As an API user
  I want to hit a URI that returns me a list of CouchDB Record Ids and Revision Ids for each child record
  So that an API client can pull down child records one per request

  Background:
    Given there is a User

  Scenario: Should give good json return value for a requested child in system
    Given I am sending a valid session token in my request headers
    And the following children exist in the system:
      | name | _id | created_at  	    	| posted_at		|
      | Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|
    When I request for child with ID 1
    Then that JSON hash of elements has these properties:
      | _id     | name  | created_by | created_at | posted_at |
      | 1       | Tom   | zubair	    | 2011-06-22 02:07:51UTC|2011-06-22 02:07:51UTC|

  @wip
  Scenario: Should give empty json return value for a requested child not in system
    Given I am sending a valid session token in my request headers
    And the following children exist in the system:
      | name | _id | created_at  	    	| posted_at		|
      | Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|
    When I request for child with ID 2
    Then I should get back a response saying null

  Scenario: Only Id and Revision properties are returned for each child record

    Given I am sending a valid session token in my request headers
    Given the following children exist in the system:
      | name |
      | Tom  |
      | Kate |
      | Jess |

    When I make a request for all child Ids
    Then I receive a JSON array
    And that list should be composed of 3 elements
    And that JSON response should be composed of items with body
    """
    	{
    	  "_id": "%SOME_STRING%",
	      "_rev": "%SOME_STRING%"
	    }
	    """


