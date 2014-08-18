Feature: So that admin can see Manage Form page, Customize Forms

  Scenario: Admins should be able to edit forms
    Given I am logged in as an admin
    And the following forms exist in the system:
      | name         |
      | Children     |
      | Enquiries    |
    And I am on forms page
    Then I should see "Enquiries"
    And I should see "Children"
    When I click the "Enquiries" link
    Then I should be on the form sections page for "Enquiries"
