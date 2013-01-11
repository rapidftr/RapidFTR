@wip
Feature: Ensure translations

  Background:
    Given I am logged in as a user with "Register Child,Edit Child,View And Search Child" permission
    Given the following translations exist:
      | locale | key        | value              |
      | de     | name       | DE Translated Name |
      | en     | name       | EN Translated Name |

  Scenario: Field label translations
    When I set the default language to de
    And I am on new child page
    Then I should see "DE Translated Name" within "#tab_basic_identity"
    And I should not see "EN Translated Name" within "#tab_basic_identity"

    And I set the default language to en
    And I am on new child page
    Then I should see "EN Translated Name" within "#tab_basic_identity"
    And I should not see "DE Translated Name" within "#tab_basic_identity"
