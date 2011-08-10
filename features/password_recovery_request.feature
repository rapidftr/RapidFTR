Feature: As an user, I should be able to request my password to be recovered.

  Scenario: To check that an user can request his password recovery
    Given I am on the login page

    Then I should see a link to the new password recovery request page
