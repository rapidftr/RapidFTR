Feature: 

  As a user
  I want to be able to export data as CSV 
  So that an user has flexibility in how the use the data in the system

  Background:
    Given the following children exist in the system:
      | name    |  last_known_location |unique_id|
      | Dan     |  London   | dan_123  |
      | Dave    |  Venice   | dave_456 |
      | Mike    |  Paris    | mike_789 |

  Scenario: A csv file with the correct number of lines is produced
    Given I am logged in
    When I search using a name of "D" 
    And I follow "Export to CSV"
    Then I should receive a CSV file with 3 lines
    And the CSV data should be:
      | name    |  last_known_location |unique_identifier|
      | Dan     |  London   | dan_123  |
      | Dave    |  Venice   | dave_456 |

  Scenario: When there are no search results, there is no csv export link
    Given I am logged in
    When I search using a name of "Z" 
    Then I should not see "Export to CSV"

  Scenario: Admins can export all child records to CSV
    Given I am logged in as an admin
    And the date/time is "Oct 23 2010"
    When I am on the admin page
    And I follow "Export All Child Records to CSV"
    Then I should receive a CSV file with 4 lines
    And the CSV data should be:
      | name    |  last_known_location |unique_identifier|
      | Dan     |  London   | dan_123  |
      | Dave    |  Venice   | dave_456 |
      | Mike    |  Paris    | mike_789 |
    And the CSV filename should be "all_records_20101023.csv"