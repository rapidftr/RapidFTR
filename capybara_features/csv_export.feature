Feature: 

  As a user
  I want to be able to export data as CSV 
  So that an user has flexibility in how the use the data in the system

  Background:
    Given the following children exist in the system:
      | name    | unique_id| created_by |
      | Dan     | dan_123  | user1      |
      | Dave    | dave_456 | user1      |
      | Mike    | mike_789 | user1      |

  @wip
  Scenario: Users can export to CSV as the result of a search
    Given I am logged in as a user with "View And Search Child,Export to Photowall/CSV/PDF" permissions
    When I search using a name of "D"
    Then I wait for 6 seconds
    And I select search result #1
    And I press "Export to CSV"
    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_identifier| created_by       | created_organisation       |
			| Dan     |dan_123  | user               | UNICEF                     |

  Scenario: When there are no search results, there is no csv export link
    Given I am logged in as a user with "View And Search Child,Export to Photowall/CSV/PDF" permissions
    When I search using a name of "Z" 
    Then I should not see "Export to CSV"

  Scenario: Admins can export some or all child records to CSV
    Given I am logged in as an admin
    And the date/time is "Oct 23 2010"
    When I am on the children listing page
    And I follow "Export All Child Records to CSV"
    Then I should receive a CSV file with 4 lines
    And the CSV data should be:
      | name    |unique_identifier| created_by | created_organisation |
      | Dan     |dan_123  | user1 | UNICEF                            |
      | Dave    |dave_456 | user1 | UNICEF                            |
      | Mike    |mike_789 | user1 | UNICEF                            |
    When I am on the children listing page
    And I follow "Export Some Records to CSV"
    And I search using a name of "D"
    And I select search result #1
    And I press "Export to CSV"
    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_id| created_by | created_organisation |
      | Dan     |dan_123  | user1      | UNICEF               |

  Scenario: User can export details of a single child to CSV
		Given I am logged in as an admin
		And I am on the child record page for "Dan"
    When  I follow "Export to CSV"

    Then I should receive a CSV file with 2 lines
    And the CSV data should be:
      | name    |unique_id| created_by |   created_organisation |
	  | Dan     |dan_123  | user1      | UNICEF                 |
