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

  @javascript
  Scenario: Users can export to CSV as the result of a search
    Given I am logged in as a user with "View And Search Child,Export to Photowall/CSV/PDF" permissions
    When I search using a name of "D"
    And I wait until "full_results" is visible
    And I select search result #1
    And I press "Export Selected to CSV"
    Then password prompt should be enabled

  Scenario: When there are no search results, there is no csv export link
    Given I am logged in as a user with "View And Search Child,Export to Photowall/CSV/PDF" permissions
    When I search using a name of "Z" 
    Then I should not see "Export to CSV"

  @javascript
  Scenario: Admins can export some or all child records to CSV
    Given I am logged in as an admin
    And the date/time is "Oct 23 2010"
    When I am on the children listing page
    And I follow "Advanced Search"
    And I search using a name of "D"
    And I select search result #1
    And I press "Export Selected to CSV"
    Then password prompt should be enabled


  @javascript
  Scenario: User can export details of a single child to CSV
   Given I am logged in as an admin
	And I am on the child record page for "Dan"
    And I follow "Export"
    When I follow "Export to CSV"
    Then password prompt should be enabled
    And I save file with password "test"

    When I follow "System settings"
    And I follow "System Logs"
    Then I should see the following log entry:
      | type       | user_name | organisation | unique_id |
      | CSV Export | admin     | UNICEF       | dan_123   |

