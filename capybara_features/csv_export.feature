Feature: 

  As a user
  I want to be able to export data as CSV 
  So that an user has flexibility in how the use the data in the system

  Background:
    Given the following children exist in the system:
      | name    | unique_id|
      | Dan     | dan_123  |
      | Dave    | dave_456 |
      | Mike    | mike_789 |

  Scenario: Users can export to CSV as the result of a search
    Given I am logged in
    When I search using a name of "D"
    And I select search result #1
    And I press "Export to CSV"
    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_identifier|
			| Dan     |dan_123  |

  Scenario: When there are no search results, there is no csv export link
    Given I am logged in
    When I search using a name of "Z" 
    Then I should not see "Export to CSV"

  Scenario: Admins can export some or all child records to CSV
    Given I am logged in as an admin
    And the date/time is "Oct 23 2010"
    When I am on the admin page
    And I follow "Export All Child Records to CSV"
    Then I should receive a CSV file with 4 lines
    And the CSV data should be:
      | name    |unique_identifier|
      | Dan     |dan_123  |
      | Dave    |dave_456 |
			| Mike    |mike_789 |
    When I go to the admin page
    And I follow "Export Some Records to CSV"
    And I search using a name of "D"
    And I select search result #1
    And I press "Export to CSV"
    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_id|
      | Dan     |dan_123  |

  Scenario: User can export details of a single child to CSV
		Given I am logged in as an admin
		And I am on the child record page for "Dan"
    When  I follow "Export to CSV"

    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_id|
			| Dan     |dan_123  |
