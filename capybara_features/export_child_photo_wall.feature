Feature:

  As a user with appropriate permissions
  I want to see the child record

  Background:
    Given I am logged in as a user with "Edit Child,View And Search Child,Export to Photowall/CSV/PDF" permission
    And the following children exist in the system:
      | name    | gender |
      | John    | Male   |

  @javascript
  Scenario: Export photo wall must be shown or hidden according to the status of exportable
    Given I am on the child record page for "John"
    And I follow "Export"
    Then I should not see "Export to Photo Wall"

    # Enable photo wall
    And I follow "Enable photo wall"
    And I follow "Export"
    Then I should see "Export to Photo Wall"
