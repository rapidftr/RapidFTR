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
    When I set the system language to "English"-"en"
    And I set the user language to "العربية"-"ar"
    Then I should see "Arabic Translated Name" translated

  @javascript
  Scenario: Field label translation missing
    When I set the system language to "العربية"-"ar"
    And I set the user language to "Русский"-"ru"
    Then I should see "Arabic Translated Name" translated
