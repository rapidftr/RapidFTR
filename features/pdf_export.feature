Feature: So that hard copy printout of missing child photos are available
  As a user
  I want to be able to export a selected subset of child search results as a PDF file

Background:
  Given I am logged in
  And I am on the child search page
  And the following children exist in the system:
    | name      | unique_id  |
    | Will      | will_uid   |
    | Willis    | willis_uid |
    | Wilma     | wilma_uid  |

Scenario: When a single record is selected and the export button is clicked, a pdf file is generated  
  When I fill in "Wil" for "Name"
  And I press "Search"
  And I select search result #1
  And I press "Export to PDF"
  Then I should receive a PDF file

Scenario: When two records are selected a pdf referring to those two records is generated  
  When I fill in "Wil" for "Name"
  And I press "Search"
  And I select search result #1
  And I select search result #3
  And I press "Export to PDF"
  Then I should receive a PDF file
  And the PDF file should have 2 pages
  And the PDF file should contain the string "will_uid"
  And the PDF file should contain the string "wilma_uid"
