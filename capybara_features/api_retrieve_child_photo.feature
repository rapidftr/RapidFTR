Feature: Retrieving a child photo using the API
  Background:
   Given there is a User
	Scenario: Should get a valid picture back by calling the correct 
    	Given I am sending a valid session token in my request headers
    	And the following children exist in the system:
      	| name | _id | created_at  	    	| posted_at		| 
      	| Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|
	When I request for the picture of the child with ID 1 and square dimensions of 400 pixels
	Then I should have received a "200" status code

