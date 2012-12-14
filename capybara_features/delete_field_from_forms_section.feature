Feature: So that admin can delete fields from a form section

  Scenario: Admins should be able to delete a field from a form section

    Given I am logged in as an admin
    And I am on the edit form section page for "basic_identity"
    When I follow "characteristics_Delete"
    Then I should not see "characteristics"
