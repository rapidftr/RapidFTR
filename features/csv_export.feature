Feature: So that an user has flexibility in how the use the data in the system
As a user
I want to be able to export data as CSV 

Background:
  Given I am logged in
  And the following children exist in the system:
    | name    |
    | Dan     |
    | Dave    |
    | Mike    |

Scenario: A csv file with the correct number of lines is produced
 When I search using a name of "D" 
 And I follow "Export to CSV"
 Then I should receive a CSV file with 3 lines

Scenario: When there are no search results, there is no csv export link
 When I search using a name of "Z" 
 Then I should not see "Export to CSV"
