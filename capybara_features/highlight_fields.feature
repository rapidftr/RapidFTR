Feature: So that I can select fields to be highlighted in view children page

  Background:
    Given I am logged in as an admin
    And I am on the admin page
    And I follow "Highlight Fields"

  @javascript
  Scenario: Adding a highlight field
    And I click text "add"
    And I select menu "Basic Identity"
    And I select menu "Nationality"
    Then I should see "Nationality" within "#highlighted-fields"

    And I remove highlight "Nationality"
    Then I should not see "Nationality" within "#highlighted-fields"



  @wip
  Scenario: A hidden highlighted field must not be visible in Child Summary

