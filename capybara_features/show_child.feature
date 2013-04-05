Feature:

  As a user with appropriate permissions
  I want to see the child record

  Background:
    Given I am logged in as a user with "View And Search Child" permission
    And the following children exist in the system:
      | name    | gender           |  photo                           |
      | John    | Male             |  "capybara_features/resources/jorge.jpg"  |

  @javascript
  Scenario: Child record must not display the edit and manage photos links

    Given I am on the child record page for "John"
    Then I should not see "Edit Photo"
    And I should not see "Manage Photo"
