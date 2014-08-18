Feature: Hide Child Record Form Fields

  As an admin user
  I want to be able to hide child details fields
  So that they do not appear on the child records forms or PDFs

  Background:
   Given I am logged in as an admin
     And the following form sections exist in the system on the "Children" form:
      | name           | unique_id      | editable | order | visible |
      | Basic details  | basic_details  | false    | 1     | true    |
      | Family details | family_details | true     | 2     | true    |
     And the following fields exists on "family_details":
      | name          | type       | display_name  |
      | name          | text_field | Name          |
      | visible_field | text_field | Visible Field |
      | hidden_field  | text_field | Hidden Field  |
     And I am on the edit field page for "hidden_field" on "family_details" form
     And I wait until "family_details" is visible
     When I uncheck "field_visible"
     And I press "Save Details" within ".field_details_panel"


  Scenario: Hidden field does not appear of form
   Given I follow "CHILDREN"
     And I am on children listing page
     And I follow "Register New Child"
     And I follow "Family details"
     And I fill in "Name" with "Will"
    When I press "Save"
    Then I should see "Child record successfully created."
     And I should see "Will"
     And I follow "Family details"
     And I should see "Visible Field"
     And I should not see "Hidden Field"

  #export to pdf not working using webdriver
  @javascript
  @wip
  Scenario: Hidden field does not appear on PDF
   Given I follow "CHILDREN"
     And I am on children listing page
     And I follow "Register New Child"
     And I follow "Family details"
     And I fill in "Name" with "Will"
    When I press "Save"
    Then I follow "Export"
    And I wait until "Export to PDF" is visible
    Then I click "//a[text()='Export to PDF']"
     And I should receive a PDF file
     And the PDF file should contain the string "Visible Field"
     And the PDF file should not contain the string "Hidden Field"
