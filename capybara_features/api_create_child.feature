Feature: Creating a child using the API

  Background:
    Given I am logged in as a user with "Register Child" permission

  Scenario: Should save created at and posted by fields as posted to the server
    Given I am sending a valid session token in my request headers
    When I create the following child:
      | created_at  | 2011-03-28 13:23:12UTC |
      | name        | bob                    |
      | posted_from | Mobile                 |
    Then the following child should be returned:
      | name        | bob                    |
      | created_at  | 2011-03-28 13:23:12UTC |
      | posted_from | Mobile                 |
    Then I receive a JSON hash
    And that hash should be composed of 16 elements
    And that JSON hash of elements strictly has these properties:
      | JSONPropertyName     |
      | name                 |
      | created_organisation |
      | created_at           |
      | posted_from          |
      | _rev                 |
      | _id                  |
      | unique_identifier    |
      | created_by           |
      | created_by_full_name |
      | couchrest-type       |
      | histories            |
      | posted_at            |
      | photo_keys           |
      | current_photo_key    |
	  | short_id			 |
      | exportable           |
    And that JSON response should be an item like
    """
		    { 
		      "name":"bob",
			    "created_at":"2011-03-28 13:23:12UTC",
			    "created_organisation":"UNICEF",
			    "posted_from":"Mobile",
			    "_rev":"%SOME_STRING%",
			    "unique_identifier":"%SOME_STRING%",
			    "_id":"%SOME_STRING%",
			    "created_by":"mary",
			    "created_by_full_name":"mary",
			    "couchrest-type":"Child",
			    "histories":[],
			    "posted_at":"%SOME_STRING%",
			    "photo_keys":[],
			    "current_photo_key":"",
          "histories":[{"changes":{"child":{"created":"2011-03-28 13:23:12UTC"}},"datetime":"2011-03-28 13:23:12UTC","user_name":"mary","user_organisation":"UNICEF"}]
			  }
			  """
