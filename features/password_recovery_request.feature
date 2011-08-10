Feature: As an user, I should be able to request my password to be recovered.

  Scenario: The link to request password recovery is available at login page
    Given I am on the login page

    Then I should see a link to the new password recovery request page


  Scenario: To check that an user is able to request password recovery
    Given I am on the login page

    When I follow "Request Password Reset"

    Then I should see "Enter your user name" 

    And I fill in "duck" for "Enter your user name"

    When I press "Request Password"

    Then I should see "Thank you. A RapidFTR administrator will contact you shortly. If possible, contact the admin directly."
