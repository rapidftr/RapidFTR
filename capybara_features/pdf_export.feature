Feature: So that hard copy printout of missing child photos are available
  As a user
  I want to be able to export selected children to a PDF file

  Background:
    Given I am logged in as a user with "View And Search Child,Export to Photowall/CSV/PDF,Edit Child" permissions
    And the following children exist in the system:
      | name      | unique_id  | created_by |
      | Will      | will_uid   | user1      |
      | Willis    | willis_uid | user1      |
      | Wilma     | wilma_uid  | user1      |

  @javascript
  Scenario: In search results, when a single record is selected and the export button is clicked, a pdf file is generated

    When I fill in "query" with "Wil"
    And I press "Go"
    And I select search result #1
    And I press "Export to PDF"
    Then password prompt should be enabled

  @javascript
  Scenario: In search results, when two records are selected a pdf referring to those two records is generated

    When I fill in "query" with "Wil"
    And I press "Go"
    And I select search result #1
    And I select search result #3
    And I press "Export to Photo Wall"
    Then password prompt should be enabled

  @allow-rescue
  @javascript
  Scenario: In search results, when no records are selected and the export button is clicked, the user is shown an error message
    Given I am on the child search page
    When I fill in "query" with "Wil"
    And I press "Go"
    And I press "Export to PDF"
    When I fill in "password-prompt-field" with "abcd"
    And I click the "OK" button
    Then I should see "You must select at least one record to be exported"


  @javascript
  Scenario: Exporting full PDF from the child page
    Given I am on the children listing page
    And I follow "Export" for child records
    And I follow "Export to PDF" for child records
    Then password prompt should be enabled

  @javascript
  Scenario: Exporting photo wall PDF from the child page
    Given I am on the saved record page for child with name "Will"
    And I follow "Export"
    And I follow "Export to Photo Wall"
    Then password prompt should be enabled

  @javascript
  Scenario: Exporting PDF when there is no photo
    Given the following children exist in the system:
      | name      | unique_id  | photo_path |
      | Billy No Photo | will_uid   |  |
   And I am on the saved record page for child with name "Billy No Photo"
    And I follow "Export"
    And I follow "Export to PDF"
    Then password prompt should be enabled

  Scenario: A user without file export permissions should not be able to export pdf/csv files
    Given I logout as "Mary"
    And an registration worker "john" with password "123"
    When I fill in "user_name" with "john"
    And I fill in "password" with "123"
    And I go and press "Login"
    When I fill in "query" with "Wil"
    And I press "Go"
    And I am on the saved record page for child with name "Will"
    Then export option should be unavailable to me

  @javascript
  Scenario: Password prompt throws an error message when left blank or filled with spaces
    Given I am on the child search page
    When I fill in "query" with "Wil"
    And I press "Go"
    And I press "Export to PDF"
    Then password prompt should be enabled
    When I fill in "password-prompt-field" with ""
    And I click the "OK" button
    Then Error message should be displayed
    When I fill in "password-prompt-field" with " "
    And I click the "OK" button
    Then Error message should be displayed
