Feature: Replications
  
  Background:
    Given I am logged in as a user with "Manage Replications" permission

  Scenario: Add, edit and delete replication
    When I am on the system settings page
    And I follow "Manage Replications"
    And I should see "Manage Replications"
    And I should see "Description"
    And I should see "RapidFTR URL"
    And I should see "Status"
    And I should see "Timestamp"
    And I should see "Actions"

    When I follow "Create Replication"
    Then I should see "Create Replication"
    And I fill in "Description" with "Test Replication"
    And I fill in "RapidFTR URL" with "localhost:99999"
    And I click the "Save" button

    Then I should see "Manage Replications"
    And I should see "Test Replication"
    And I should see "http://localhost:99999/"
    And I should see "Failed"

    Then I follow "Edit"
    Then I should see "Edit Replication"
    And I fill in "Description" with "New Replication"
    And I fill in "RapidFTR URL" with "localhost:88888"
    And I click the "Save" button

    Then I should see "Manage Replications"
    And I should see "New Replication"
    And I should see "http://localhost:88888/"
    And I should not see "Test Replication"
    And I should not see "http://localhost:99999/"

    And I follow "Delete"
    And I should not see "New Replication"
    And I should not see "http://localhost:88888/"
