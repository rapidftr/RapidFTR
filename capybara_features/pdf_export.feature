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

    When I fill in "Wil" for "query"
    And I press "Go"
    And I select search result #1
    And I press "Export to PDF"
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button

  @javascript
  Scenario: In search results, when two records are selected a pdf referring to those two records is generated

    When I fill in "Wil" for "query"
    And I press "Go"
    And I select search result #1
    And I select search result #3
    And I press "Export to Photo Wall"
    Then I wait for 10 seconds
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button
# TODO
#    Then I should receive a PDF file
#    And the PDF file should have 2 pages

  @allow-rescue
  @javascript
  Scenario: In search results, when no records are selected and the export button is clicked, the user is shown an error message
    Given I am on the child search page

    When I fill in "Wil" for "query"
    And I press "Go"
    And I press "Export to PDF"
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button

    Then I should see "You must select at least one record to be exported"


  @javascript
  Scenario: Exporting full PDF from the child page
    Given I am on the saved record page for child with name "Will"
    And I follow "Export"
    And I follow "Export to PDF"
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button

#TODO
#    Then I should receive a PDF file
#    And the PDF file should have 2 pages
#    And the PDF file should contain the string "Will"

  @javascript
  Scenario: Exporting photo wall PDF from the child page
    Given I am on the saved record page for child with name "Will"
    And I follow "Export"
    And I follow "Export to PDF"
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button

#TODO
#    Then I should receive a PDF file
#    And the PDF file should have 1 page
#    And the PDF file should not contain the string "Will"

  @javascript
  Scenario: Exporting PDF when there is no photo
    Given the following children exist in the system:
      | name      | unique_id  | photo_path |
      | Billy No Photo | will_uid   |  |
   And I am on the saved record page for child with name "Billy No Photo"
    And I follow "Export"
    And I follow "Export to PDF"
    When I fill in "abcd" for "password-prompt-field"
    And I click the "OK" button

  @javascript
  Scenario: A user without file export permissions should not be able to export pdf/csv files
    Given I logout
    And an registration worker "john" with password "123"
    When I fill in "john" for "user_name"
    And I fill in "123" for "password"
    And I select "Login"
    When I fill in "Wil" for "query"
    And I press "Go"
    And I am on the saved record page for child with name "Will"
    Then export option should be unavailable to me
