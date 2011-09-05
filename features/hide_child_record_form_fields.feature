Feature: Hide Child Record Form Fields

  As an admin user
  I want to be able to hide child details fields
  So that they don not appear on the child records forms or PDFs


  Background:
   Given I am logged in as an admin
     And the following form sections exist in the system:
      | name           | unique_id      | editable | order | enabled |
      | Basic details  | basic_details  | false    | 1     | true    |
      | Family details | family_details | true     | 2     | true    |
     And the following fields exists on "family_details":
      | name          | type       | display_name  |
      | name          | text_field | Name          |
      | visible_field | text_field | Visible Field |
      | hidden_field  | text_field | Hidden Field  |
     And I am on the edit field page for "hidden_field" on "family_details" form
    When I fill in "false" for "Visible"
     And I press "Save"
    Then I should see "hidden_field" in the list of fields
     And I should see "Hidden"


  Scenario: Hidden field does not appear of form
   Given I follow "Home"
     And I am on children listing page
     And I follow "Register New Child"
     And I fill in "Name" with "Will"
    When I press "Save"
    Then I should see "Child record successfully created."
     And I should see "Will"
     And I should see "Visible Field"
     And I should not see "Hidden Field"


  Scenario: Hidden field does not appear on PDF
   Given I follow "Home"
     And I am on children listing page
     And I follow "Register New Child"
     And I fill in "Name" with "Will"
    When I press "Save"
    Then I follow "Export to PDF"
     And I should receive a PDF file
     And the PDF file should contain the string "Visible Field"
     And the PDF file should not contain the string "Hidden Field"

