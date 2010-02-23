
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

Scenario: Searching for a child given his name
  Given someone has entered a child with the name "Willis"
  And I am on the search page
  When I fill in "Willis" for "Name"
  And I press "Search"
  Then I should be on the child summaries page
  And I should see "Willis" in the column "Name"
