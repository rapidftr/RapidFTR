Feature: So that hard copy printout of missing child photos are available
  As a user
  I want to be able to export selected children to a PDF or a CSV file

  Background:
    Given I am logged in as a user with "View And Search Child,Export to Photowall,Export to CSV,Export to PDF,Export to CPIMS,Edit Child" permissions
    And the following children exist in the system:
      | name      | unique_id  | created_by |
      | Will      | will_uid   | user1      |
      | Willis    | willis_uid | user1      |
      | Wilma     | wilma_uid  | user1      |

  @javascript @search
  Scenario Outline: : In search results, when a single record is selected and the export button is clicked, a file is generated
    When I fill in "query" with "Wil"
    And I press "Go"
    And I select search result #1
    When I press "<action>"
    Then password prompt should be enabled

  Examples:
    |action                       |
    |Export Selected to Photo Wall|
    |Export Selected to PDF       |
    |Export Selected to CSV       |
    |Export Selected to CPIMS     |

  Scenario: When there are no search results, there is no csv export link
    When I search using a name of "Z"
    Then I should not see "Export to CSV"

  @javascript @search
  Scenario Outline: In search results, when two records are selected a file referring to those two records is generated
    When I fill in "query" with "Wil"
    And I press "Go"
    And I select search result #1
    And I select search result #3
    When I press "<action>"
    Then password prompt should be enabled

  Examples:
    |action                       |
    |Export Selected to Photo Wall|
    |Export Selected to PDF       |
    |Export Selected to CSV       |
    |Export Selected to CPIMS     |

  @javascript @search
  Scenario Outline: In search results, when no records are selected and the export button is clicked, the user is shown an error message
    Given I am on the search page
    When I fill in "query" with "Wil"
    And I press "Go"
    And I press "<action>"
    When I fill in "password-prompt-field" with "abcd"
    And I click the "OK" button
    Then I should see "You must select at least one record to be exported"

  Examples:
    |action                       |
    |Export Selected to Photo Wall|
    |Export Selected to PDF       |
    |Export Selected to CSV       |
    |Export Selected to CPIMS     |

  @javascript
  Scenario Outline: Exporting full PDF from the child page
    Given I am on the children listing page
    When I follow "Export" for child records
    And I follow "<action>" for child records
    Then password prompt should be enabled

  Examples:
    |action                  |
    |Export All to Photo Wall|
    |Export All to PDF       |
    |Export All to CSV       |
    |Export All to CPIMS     |

  @javascript
  Scenario Outline: User can export details of a single child to file
    Given I am on the child record page for "Will"
    When I follow "Export"
    And I follow "<action>"
    Then password prompt should be enabled

  Examples:
    |action              |
    |Export to Photo Wall|
    |Export to PDF       |
    |Export to CSV       |
    |Export to CPIMS     |

  @javascript
  Scenario: Exporting PDF when there is no photo
    Given the following children exist in the system:
      | name           | unique_id  | photo_path |
      | Billy No Photo | billy_no_photo_uid   |  |
    When I am on the saved record page for child with name "Billy No Photo"
    And I follow "Export"
    And I follow "Export to PDF"
    Then password prompt should be enabled


  Scenario: A user without file export permissions should not be able to export files
    Given I logout as "Mary"
    And an registration worker "john" with password "123"
    When I fill in "user_name" with "john"
    And I fill in "password" with "123"
    And I go and press "Login"
    And I fill in "query" with "Wil"
    And I press "Go"
    And I am on the saved record page for child with name "Will"
    Then "export" option should be unavailable to me

  @javascript @search
  Scenario: Password prompt throws an error message when left blank or filled with spaces
    Given I am on the search page
    And I fill in "query" with "Wil"
    And I press "Go"
    And I press "Export Selected to PDF"
    Then password prompt should be enabled
    And I fill in "password-prompt-field" with ""
    And I click the "OK" button
    Then Error message should be displayed

  @javascript @search
  Scenario Outline: A user can export advanced search results
    Given I am on child advanced search page
    When I click text "Select A Criteria"
    And  I click text "Name"
    And I fill in "criteria_list[0][value]" with "Will"
    And I search
    And I wait for the page to load
    When I select search result #1
    And I press "<action>"
    Then password prompt should be enabled

  Examples:
    |action                       |
    |Export Selected to Photo Wall|
    |Export Selected to PDF       |
    |Export Selected to CSV       |
    |Export Selected to CPIMS     |
