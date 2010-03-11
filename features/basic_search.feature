
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

Scenario: Searching for a child given his name
  Given I am logged in
  And someone has entered a child with the name "Willis"
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
  When I search using a name of "Lisa"
  Then I should be on the saved record page for child with name "Lisa"

Scenario: Search parameters are displayed in the search results
  Given I am logged in 
  And no children exist
  And I am on the search page
  When I fill in "Will" for "Name"
  And I fill in "xyz" for "Child ID"
  And I press "Search"
  Then I should be on the child summaries page
  And the "Name" field should contain "Will"
  And the "Child ID" field should contain "xyz"

Scenario: Each search result has a link to the full child record
  Given I am logged in
  And someone has entered a child with the name "Willis"
  And someone has entered a child with the name "Will"
  When I search using a name of "W"
  Then I should see a link to the saved record page for child with name "Willis"
  And I should see a link to the saved record page for child with name "Will"

Scenario: Thumbnails are displayed for each search result, if requested
  Given I am logged in
  And there is a child with the name "Dave" and a photo from "features/resources/jorge.jpg"
  And there is a child with the name "Daryl" and a photo from "features/resources/jorge.jpg"
  When I search using a name of "D"
  Then I should see an image from the photo resource for child with name "Dave"

