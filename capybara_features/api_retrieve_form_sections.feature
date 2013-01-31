Feature:
  
  As an API user
  I want to hit a URI that gives me all published form sections
  So that an API client can have all fields related to entering information

  Background:
    Given there is a User
  Scenario: A logged in API user should be able to retrieve all published form sections

    Given I am sending a valid session token in my request headers

    When I make a request for published form sections
    Then I receive a JSON array
    And that JSON response should be composed of items with body 
    	"""
    	{
    	  "id": "%SOME_STRING%",
	      "_rev": "%SOME_STRING%",
	      "_id": "%SOME_STRING%",
	      "unique_id": "%SOME_STRING%",
	      "order": "%SOME_INTEGER%",
	      "visible": "%SOME_BOOL%",
	      "fields": "%SOME_FIELD_ARRAY%",
	      "couchrest_type": "%SOME_STRING%",
	      "description": "%SOME_STRING%",
	      "perm_visible": "%SOME_BOOL%"
	    }
	    """
