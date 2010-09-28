Feature:
  So that we can add a numeric field to a formsection
  
  Background:
    Given I am logged in as an admin

  Scenario: creating a numeric field
    Given I am on the manage fields page for "family_details"
    And I follow "Add Custom Field"
    When I follow "Numeric Field"
    And I fill in "My_new_numeric_field" for "Name"
    And I fill in "Help for a numeric field" for "Help text"
    And I fill in "My new number field" for "Display name"
    And I press "Create"
    Then I should see "Field successfully added"
    And I should see "My_new_numeric_field" in the list of fields
    When I am on children listing page
    And I follow "New child"
    And I fill in "2345" for "My new number field"
    And I press "Save"
    Then I should see "My new number field: 2345"