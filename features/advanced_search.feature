@wip
Feature: So that I can find a child that has been entered in to RapidFTR
  As a user of the website
  I want to use the advanced search criteria to find all relevant results

  Background:
    Given I am logged in
    And I am on child advanced search page

  Scenario: Searching for children by the user who entered the details

    Given the following children exist in the system:
      | name   | created_by   |
      | Willis | aid_worker_1 |
      | Will   | aid_worker_2 |

    When I check "created_by"
    And I fill in "aid_worker_1" for "created_by_value"
    And I press "Search"

    Then I should be on the child advanced search results page

#    And I should see "Willis" in the search results
