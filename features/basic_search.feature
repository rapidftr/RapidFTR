Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

Background:
  Given I am logged in
  And I am on the search page

Scenario: Searching for a child given his name
  Given the following children exist in the system:
    | name   |
    | Willis |
    | Will   |
  When I fill in "Will" for "Name"
  And I press "Search"
  Then I should be on the child summaries page
  And I should see "Willis" in the column "Name"

Scenario: Searching for a child given his unique identifier
  Given the following children exist in the system:
    | name   	| last_known_location 	| reporter |
    | andreas	| London		            | zubair   |
    | zak	    | London		            | zubair   |
  When I fill in "zubairlon" for "Child ID"
  And I press "Search"
  Then I should be on the child summaries page
  And I should see "andreas" in the column "Name"

Scenario: Searches that yield a single record should redirect directly to that record
  Given the following children exist in the system:
    | name   	| 
    | Lisa	|
  When I search using a name of "Lisa"
  Then I should be on the saved record page for child with name "Lisa"

Scenario: Search parameters are displayed in the search results
  Given no children exist
  When I fill in "Will" for "Name"
  And I fill in "xyz" for "Child ID"
  And I press "Search"
  Then I should be on the child summaries page
  And the "Name" field should contain "Will"
  And the "Child ID" field should contain "xyz"

Scenario: 'Show thumbnails' checkbox is unchecked in search results if it was unchecked for the search
  Given no children exist
  When I uncheck "Show thumbnails"
  And I press "Search"
  Then the "Show thumbnails" checkbox should not be checked

Scenario: 'Show thumbnails' checkbox is checked in search results if it was checked for the search
  Given no children exist
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
  Then I should see an image from the photo resource for child with name "Willis"
  Then I should see an image from the photo resource for child with name "Will"

Scenario: Thumbnails are not displayed for each search result, if not requested
Given the following children exist in the system:
    | name   	| 
    | Willis	|
    | Will	|
  When I fill in "W" for "Name"
  And I uncheck "Show thumbnails" 
  And I press "Search"
  Then I should not see an image from the photo resource for child with name "Willis"
