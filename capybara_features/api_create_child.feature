Feature: Creating a child using the API

  Background:
    Given there is a User

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
    And that hash should be composed of 22 elements
    And that JSON hash of elements strictly has these properties:
      | JSONPropertyName     |
      | duplicate            |
      | name                 |
      | created_by_full_name |
      | created_at           |
      | posted_from          |
      | _rev                 |
      | _id                  |
      | reunited             |
      | updated_at           |
      | flag                 |
      | unique_identifier    |
      | nick_name            |
      | investigated         |
      | created_by           |
      | type                 |
      | histories            |
      | posted_at            |
      | photo_keys           |
      | current_photo_key    |
      | last_known_location  |
      | origin               |
      | age                  |
    And that JSON response should be an item like
    """
    {
    "name": "bob",
    "created_by_full_name": null,
    "posted_from": "Mobile",
    "created_at": "2011-03-28 13:23:12UTC",
    "_rev": "%SOME_STRING%",
    "current_photo_key": null,
    "photo_keys": [],
    "unique_identifier": "%SOME_STRING%",
    "_id": "%SOME_STRING%",
    "created_by": "mary",
    "type": "Child",
    "histories": [],
    "posted_at": "%SOME_STRING%"
    }  
    """
