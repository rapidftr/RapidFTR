Feature: Creating a child using the API
  Background:
   Given there is a User

	Scenario: Should save created at field as posted to the server
    Given I am sending a valid session token in my request headers
		When I create the following child:
			| created_at  | 2011-03-28 13:23:12UTC  |
			| name				| bob  |
		Then the following child should be returned:
			| name 				| bob									|
			| created_at  | 2011-03-28 13:23:12UTC |
