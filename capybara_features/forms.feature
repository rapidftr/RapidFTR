Feature: So that admin can see Manage Form page, Customize Forms

  Scenario: Admins should be able to edit forms
    Given I am logged in as an admin
    And the following forms exist in the system:
      | name         |
      | Children     |
      | Enquiries    |
    And I am on forms page
    Then I should see "Enquiries Form"
    And I should see "Children Form"
    When I click the "Enquiries Form" link
    Then I should be on the form sections page for "Enquiries"
