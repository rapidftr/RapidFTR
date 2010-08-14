Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

Background:
  Given I am logged in
  And I am on the child search page

Scenario: Searching for a child given his name
  Given the following children exist in the system:
    | name   |
    | Willis |
    | Will   |
  When I fill in "Will" for "Name"
  And I press "Search"
  Then I should be on the child search results page
  And I should see "Willis" in the search results

Scenario: Searching for a child given his unique identifier
  Given the following children exist in the system:
    | name   	| last_known_location 	| reporter | unique_id |
    | andreas	| London		            | zubair   | zubairlon123 |
    | zak	    | London		            | zubair   | zubairlon456 |
  When I fill in "zubairlon123" for "Child ID"
  And I press "Search"
  Then I should be on the saved record page for child with name "andreas"

Scenario: Searches that yield a single record should redirect directly to that record
  Given the following children exist in the system:
    | name   	| 
    | Lisa	|
  When I search using a name of "Lisa"
  Then I should be on the saved record page for child with name "Lisa"

Scenario: Search parameters are displayed in the search results
  When I fill in "Will" for "Name"
  And I fill in "xyz" for "Child ID"
  And I press "Search"
  Then I should be on the child search results page
  And the "Name" field should contain "Will"
  And the "Child ID" field should contain "xyz"

Scenario: 'Show thumbnails' checkbox is unchecked in search results if it was unchecked for the search
  When I uncheck "Show thumbnails"
  And I press "Search"
  Then the "Show thumbnails" checkbox should not be checked

Scenario: 'Show thumbnails' checkbox is checked in search results if it was checked for the search
  When I check "Show thumbnails"
  And I press "Search"
  Then the "Show thumbnails" checkbox should be checked

Scenario: Each search result has a link to the full child record
  Given the following children exist in the system:
    | name   	| 
    | Willis	|
    | Will	|
  When I search using a name of "W"
  Then I should see a link to the saved record page for child with name "Willis"
  And I should see a link to the saved record page for child with name "Will"
 
Scenario: Thumbnails are displayed for each search result, if requested
  Given the following children exist in the system:
    | name   	| 
    | Willis	|
    | Will	|
  When I fill in "W" for "Name"
  And I check "Show thumbnails" 
  And I press "Search"
  Then I should see the thumbnail of "Willis"
  And I should see the thumbnail of "Will"

Scenario: Thumbnails are not displayed for each search result, if not requested
Given the following children exist in the system:
    | name   	| 
    | Willis	|
    | Will	|
  When I fill in "W" for "Name"
  And I uncheck "Show thumbnails" 
  And I press "Search"
  Then I should not see the thumbnail of "Willis"

Scenario: Not seing "No results found" when first enter search page
  Given the following children exist in the system:
    | name   |
    | Willis |
    | Will   |
  When I fill in "Will" for "Name"
  And I press "Search"
  Then I should be on the child search results page
  And I should see "Willis" in the search results


Scenario: Searching for a child given his name returns no results
  Given I am on the child search page
  Then I should not see "No results found"
