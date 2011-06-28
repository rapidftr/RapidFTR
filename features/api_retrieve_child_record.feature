Feature: Retrieving a child record using the API
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

	Scenario: Should give empty json return value for a requested child not in system
    	Given I am sending a valid session token in my request headers
    	And the following children exist in the system:
      	| name | _id | created_at  	    	| posted_at		| 
      	| Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|
	When I request for child with ID 2
	Then I should get back a response saying null

