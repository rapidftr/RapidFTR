Feature:
  
  As an API user
  I want to hit a URI that returns me the administration contact information

  Background:
   Given there is a User
  Scenario: Only Id and Revision properties are returned for each child record
	Given the following admin contact info: 
	  | key | value |
	  | name | John Smith |
	  | organization | UNICEF |

    When I make a request for administrator contact page
    Then I receive a JSON response: 
	  | name | organization |
	  | John Smith | UNICEF | 
