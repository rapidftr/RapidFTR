Feature: Replications

  @javascript
  Scenario: Add, edit and delete replication
    Given I am logged in as a user with "Manage Replications" permission
    When I am on devices listing page
    And I should see "Configure a Server"

    When I follow "Configure a Server"
    Then I should see "Configure a Server"
    And I fill in "Description" with "Test Replication"
    And I fill in "RapidFTR URL" with "localhost:99999"
    And I fill in "User Name" with "rapidftr"
    And I fill in "Password" with "rapidftr"
    And I make sure that the Replication Configuration request fails
    And I click the "Save" button

    Then I should see "The URL/Username/Password that you entered is incorrect"
    And I make sure that the Replication Configuration request succeeds
    And I fill in "Password" with "rapidftr"
    And I click the "Save" button

    Then I should see "Configure a Server"
    And I should see "Test Replication"
    And I should see "http://localhost:99999/"
    And I should see "rapidftr"
    And I should see "In Progress"

    Then I follow "Edit"
    Then I should see "Edit Configuration"
    And I fill in "Description" with "New Replication"
    And I fill in "RapidFTR URL" with "localhost:88888"
    And I fill in "User Name" with "rapidftr"
    And I fill in "Password" with "rapidftr"
    And I make sure that the Replication Configuration request succeeds
    And I click the "Save" button

    Then I should see "Configure a Server"
    And I should see "New Replication"
    And I should see "http://localhost:88888/"
    And I should not see "Test Replication"
    And I should not see "http://localhost:99999/"

    And I follow "Delete"
    And I click OK in the browser popup
    Then I should not see "New Replication"
    And I should not see "http://localhost:88888/"
    And I clear the Replication Configuration expectations
