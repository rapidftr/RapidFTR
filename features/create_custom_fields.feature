Feature:
  So that we can add a numeric field to a formsection
  
  Background:
    Given I am logged in as an admin
     And the following form sections exist in the system:
    | name | unique_id |
    | Basic details | basic_details |

  Scenario: creating a numeric field
    Given I am on the manage fields page for "basic_details"
    And I follow "Add Custom Field"
    When I follow "Numeric Field"
    And I fill in "My_new_numeric_field" for "Name"
    And I fill in "Help for a numeric field" for "Help text"
    And I press "Create"
    Then I should see "Field successfully added"