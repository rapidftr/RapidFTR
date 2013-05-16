Feature:

  As a user with appropriate permissions
  I want to see the child record

  Background:
    Given I am logged in as a user with "Edit Child,View And Search Child,Export to Photowall" permission
    And the following children exist in the system:
      | name | gender |
      | John | Male   |

  @javascript
  Scenario: Export Photo Wall should ask for password
    Given I am on the child record page for "John"
    And I follow "Export"
    And I follow "Export to Photo Wall"
    Then I should see "Enter password to encrypt file"
    When I fill in "  " for "password-prompt-field"
    And I click the "OK" button
    Then I should see "Enter a valid password"


