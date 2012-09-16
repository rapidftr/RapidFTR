Feature:
  
  As an API user
  I want to hit a URI that returns me a list of CouchDB Record Ids and Revision Ids for each child record
  So that an API client can pull down child records one per request

  Background:
   Given there is a User
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
    	  "id": "%SOME_STRING%",
	      "rev": "%SOME_STRING%" 
	    }
	    """
