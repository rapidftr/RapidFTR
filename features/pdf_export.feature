Feature: So that hard copy printout of missing child photos are available
  As a user
  I want to be able to export selected children to a PDF file

  Background:
    Given I am logged in
    And the following children exist in the system:
      | name      | unique_id  |
      | Will      | will_uid   |
      | Willis    | willis_uid |
      | Wilma     | wilma_uid  |

  Scenario: In search results, when a single record is selected and the export button is clicked, a pdf file is generated  
    Given I am on the child search page

    When I fill in "Wil" for "Name"
    And I press "Search"
    And I select search result #1
    And I press "Export to PDF"

    Then I should receive a PDF file

  Scenario: In search results, when two records are selected a pdf referring to those two records is generated  
    Given I am on the child search page

    When I fill in "Wil" for "Name"
    And I press "Search"
    And I select search result #1
    And I select search result #3
    And I press "Export to Photo Wall"

    Then I should receive a PDF file
    And the PDF file should have 2 pages
    And the PDF file should contain the string "will_uid"
    And the PDF file should contain the string "wilma_uid"

  @allow-rescue
  Scenario: In search results, when no records are selected and the export button is clicked, the user is shown an error message
    Given I am on the child search page

    When I fill in "Wil" for "Name"
    And I press "Search"
    And I press "Export to PDF"

    Then I should see "You must select at least one record to be exported"

  Scenario: Exporting full PDF from the child page
    Given I am on the saved record page for child with name "Will"
    And I follow "Export to PDF"

    Then I should receive a PDF file
    And the PDF file should have 6 pages
    And the PDF file should contain the string "will_uid"
    And the PDF file should contain the string "Will"

  Scenario: Exporting photo wall PDF from the child page
    Given I am on the saved record page for child with name "Will"
    And I follow "Export to Photo Wall"

    Then I should receive a PDF file
    And the PDF file should have 1 page
    And the PDF file should contain the string "will_uid"
    And the PDF file should not contain the string "Will"

  Scenario: Exporting PDF when there is no photo
    Given the following children exist in the system:
      | name      | unique_id  | photo_path |
      | Billy No Photo | will_uid   |  |
   And I am on the saved record page for child with name "Billy No Photo"
   And I follow "Export to PDF"
   Then I should receive a PDF file
