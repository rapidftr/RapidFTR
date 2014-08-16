Feature:
  As a field agent using the website
  I would like to edit the photograph so that it represents the correct orientation

  Background:
    Given I am logged in as a user with "Register Child,Edit Child" permission

  Scenario: Editing the primary photo
    Given I am on the new child page

    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"

    Then I should see "Child record successfully created"
    And I should see the photo of "John"

    When I follow "Edit photo"
    Then I should see "Rotate Anti-Clockwise"

    When I follow "Rotate Anti-Clockwise"
    And I press "Save"
    Then I should see the photo of "John"
