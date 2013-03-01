Feature: Ensure translations

  Background:
    Given I am logged in as a user with "Admin" permission
    Given the following translations exist:
      | locale | key        | value                   |
      | ar     | xxxx       | Arabic Translated Name  |
      | en     | xxxx       | English Translated Name |
      | ru     | yyyy       | Whatever                |

  @javascript
  Scenario: Field label translations
    When I set the system language to "ar"
    And I set the user language to "en"
    Then I should see "English Translated Name" translated

  Scenario: Field label translations when incomplete translation
    When I set the system language to "ar"
    And I set the user language to "ru"
    Then I should see "Arabic Translated Name" translated
