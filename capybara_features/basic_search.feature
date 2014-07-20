@search
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results

  Background:
    Given I am logged in

  Scenario: Searching for a child given his name
    Given the following children exist in the system:
      | name   |
      | Willis |
      | Will   |
    When I fill in "query" with "Will"
    And I press "Go"
    And I should see "Willis" in the search results

  Scenario: Searching for a child given his short id
    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id     |
      | andreas	| London		            | zubair   | zubairlon123  |
      | zak	    | London		            | zubair   | somerlion     |
    When I fill in "query" with "rlon"
    And I press "Go"
    Then I should be on the saved record page for child with name "andreas"

  Scenario: Searches that yield a single record should redirect directly to that record
    Given the following children exist in the system:
      | name   	|
      | Lisa	|
    When I fill in "query" with "Lisa"
    And I press "Go"
    Then I should be on the saved record page for child with name "Lisa"

  Scenario: Search parameters are displayed in the search results
    When I fill in "query" with "Will"
    And I press "Go"
    Then I should be on the child search results page
    And the "query" field should contain "Will"

  Scenario: Each search result has a link to the full child record
    Given the following children exist in the system:
      | name   	|
      | Willis	|
      | Will	|
    When I search using a name of "Will"
    Then I should see a link to the saved record page for child with name "Willis"
    And I should see a link to the saved record page for child with name "Will"

  Scenario: Thumbnails are displayed for each search result, if requested
    Given the following children exist in the system:
      | name   	|
      | Willis	|
      | Will	|
    When I fill in "query" with "Will"
    And I press "Go"
    Then I should see the thumbnail of "Willis"
    And I should see the thumbnail of "Will"

  Scenario: Not seing "No results found" when first enter search page
    Given the following children exist in the system:
      | name   |
      | Willis |
      | Will   |
    When I fill in "query" with "Will"
    And I press "Go"
    Then I should be on the child search results page
    And I should see "Willis" in the search results

  Scenario: Searching for a child given his name returns no results
    Given I am on the child search page
    Then I should not see "No results found"

  @wip
  Scenario: Creating an invalid search
    Given I am on the children listing page
    Then I should not see any errors
    When I fill in "query" with "   "
    And I press "Go"
    Then I should be on the children listing page

  Scenario: Creating a search with non standard queries
    Given I am on the child search page
    Then I should not see any errors
    When I fill in "query" with "\"
    And I press "Go"
    Then I should be on the child search results page

  Scenario: User with unlimited access can see all children
    Given a user "field_admin" with "View And Search Child" permission
      And a user "field_worker" with "Register Child" permission
      And the following children exist in the system:
       | name   | created_by   |
       | Andrew | field_worker |
       | Peter  | field_admin  |
     And I am logged out
     When I am logged in as "field_admin"
      And I follow "View Records"
     Then I should see "Andrew"
      And I should see "Peter"

  Scenario: User with limited access cannot see all children
    Given a user "field_admin" with "View And Search Child" permission
      And a user "field_worker" with "Register Child" permission
      And the following children exist in the system:
       | name   | created_by   |
       | Andrew | field_worker |
       | Peter  | field_admin  |
     And I am logged out
     When I am logged in as "field_worker"
      And I follow "View Records"
     Then I should see "Andrew"
      And I should not see "Peter"

  Scenario: User should be able to search from any page
    Given I am on children listing page
    And the following children exist in the system:
      | name   |
      | Andrew |
    And I fill in "query" with "Andrew"
    And I press "Go"
    Then I should be on the saved record page for child with name "Andrew"
