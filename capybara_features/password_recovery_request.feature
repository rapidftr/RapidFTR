Feature: As an user, I should be able to request my password to be recovered.

  Scenario: To check that an user is able to request password recovery
    Given I am on the login page
    When I follow "Request Password Reset"
    And I fill in "Enter your user name" with "any old thing"
    And I press "Request Password"
    Then I should see "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."

  Scenario: An Admin user can see and hide notifications
    Given a password recovery request for duck
    And I am logged in as an admin
    And I am on the home page
    Then I should see "duck"

    When I follow "hide"
    Then I should not see "duck"

  Scenario: An Admin user is able to see a link to the user profile of a given password recovery request
    Given a user "duck" with password "iamevil"
    And a password recovery request for duck
    And I am logged in as an admin
    And I am on the home page
    Then I should see a link to the user details page for "duck"
