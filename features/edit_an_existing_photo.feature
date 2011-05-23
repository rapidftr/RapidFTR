Feature:

  As a field agent using the website
  I would like to edit the photograph so that it represents the correct orientation

  Background:
    Given I am logged in

  Scenario: Editing the primary photo

    Given I am on the new child page

    When I fill in "Haiti" for "Last known location"
    And I fill in "John" for "Name"
    And I attach a photo "features/resources/jorge.jpg"
    And I press "Save"

    Then I should see "Child record successfully created"
    And I should see the photo of "John"
    
    When I follow "Edit photo"
    Then I should see "Rotate Anti-Clockwise"
    
    When I follow "Rotate Anti-Clockwise"
    And I press "Save"
    Then I should see the photo of "John"