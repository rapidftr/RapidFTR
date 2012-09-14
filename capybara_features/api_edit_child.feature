Feature: Editing a child using the API
  Background:
   Given there is a User
	Scenario: Should save created at and posted by fields as posted to the server
    	Given I am sending a valid session token in my request headers
    	And the following children exist in the system:
      	| name | _id | created_at  	    	| posted_at		| 
      	| Tom  | 1   | 2011-06-22 02:07:51UTC	| 2011-06-22 02:07:51UTC|
		When I edit the following child:
		"""
		{
		 "_id": "1",
		 "photo": "",
		 "audio": "",
		 "name": "Jorge"
		}
		"""
	Then that JSON hash of elements has these properties:
	     | _id     | name  | created_by | user_name	| histories	| last_updated_at | created_at | posted_at | 
	     | 1       | Jorge | zubair	    | mary	| "%SOME_ARRAY%"| "%SOME_DATE%"	  |2011-06-22 02:07:51UTC|2011-06-22 02:07:51UTC|
