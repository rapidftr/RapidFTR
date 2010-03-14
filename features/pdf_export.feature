Feature: So that hard copy printout of missing child photos are available
  As a user
  I want to be able to export a selected subset of child search results as a PDF file

Background:
  Given I am logged in
  And I am on the child search page
  And the following children exist in the system:
    | name      |
    | Willis    |
    | Will      |
    | William   |

Scenario: A pdf file is generated when a single record is selected and the export button is clicked 
  When I fill in "Will" for "Name"
  And I press "Search"
  And I select the first search result 
  And I press "Export to PDF"
  Then I should receive a PDF file
