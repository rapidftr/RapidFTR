
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

Scenario: Searching for a child given his name
  Given I am logged in
  Given someone has entered a child with the name "Willis"
  And someone has entered a child with the name "Will"
  And I am on the search page
  When I fill in "Will" for "Name"
  And I press "Search"
  Then I should be on the child summaries page
  And I should see "Willis" in the column "Name"

Scenario: Searching for a child given his unique identifier
  Given I am logged in
  Given a user "zubair" has entered a child found in "London" whose name is "andreas"
  And a user "zubair" has entered a child found in "London" whose name is "zak"
  And I am on the search page
  When I fill in "zubairlon" for "Child ID"
  And I press "Search"
  Then I should be on the child summaries page
  And I should see "andreas" in the column "Name"

Scenario: Searches that yield a single record should redirect directly to that record
  Given I am logged in
  And no children exist
  And someone has entered a child with the name "Lisa"
  And I am on the search page
  When I fill in "Lisa" for "Name"
  And I press "Search"
  Then I should be on the saved record page for child with name "Lisa"
