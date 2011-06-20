Feature: Creating a child using the API
  Background:
   Given there is a User
	Scenario: Should save created at and posted by fields as posted to the server
    Given I am sending a valid session token in my request headers
		When I create the following child:
			| created_at  | 2011-03-28 13:23:12UTC  |
			| name				| bob  |
			| posted_from | Mobile |
		Then the following child should be returned:
			| name 				| bob									|
			| created_at  | 2011-03-28 13:23:12UTC |
			| posted_from | Mobile |
		Then I receive a JSON hash
		And that hash should be composed of 12 elements
		And that JSON hash of elements has these properties:
		    | JSONPropertyName |
		    | name |
		    | created_at |
		    | posted_from |
		    | _rev |
		    | _id |
		    | unique_identifier |
		    | created_by |
		    | couchrest-type |
		    | histories |
		    | posted_at |
		    | photo_keys |
		    | current_photo_key |
		And that JSON response should be composed of items with body
		    """
		    { 
		      "name":"bob",
			    "created_at":"2011-03-28 13:23:12UTC",
			    "posted_from":"Mobile",
			    "_rev":"%SOME_STRING%",
			    "unique_identifier":"%SOME_STRING%",
			    "_id":"%SOME_STRING%",
			    "created_by":"mary",
			    "couchrest-type":"Child",
			    "histories":[],
			    "posted_at":"%SOME_STRING%",
			    "photo_keys":[],
			    "current_photo_key":null
			  }
			  """
			  