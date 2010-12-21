Feature:
  
  As an API user
  I want to hit a URI that returns me the administration contact information

  Scenario: Only Id and Revision properties are returned for each child record
	Given the following admin contact info: 
	  | key | value |
	  | name | John Smith |
	  | organization | UNICEF |
    And I am logged in

    When I go to the json formatted administrator contact page
    Then I receive a JSON response: 
	  | name | organization |
	  | John Smith | UNICEF | 
