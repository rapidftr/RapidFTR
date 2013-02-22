Feature: Ensure translations

  Background:
    Given I am logged in as a user with "Admin" permission
    Given the following translations exist:
      | locale | key        | value                   |
      | ar     | name       | Arabic Translated Name  |
      | en     | name       | English Translated Name |

  Scenario: Field label translations
    When I set the default language to "ar"
    Then I should see "Arabic Translated Name" translated
    And I should not see "English Translated Name" translated

    And I set the default language to "en"
    And I am on new child page
    Then I should see "English Translated Name" translated
    And I should not see "Arabic Translated Name" translated

  Scenario: Field label translations when hasn't translation
    When I set the default language to "ar"
    Then I should see "Arabic Translated Name" translated
    And I should not see "Russian Translated Name" translated

    And I set the default language to "ru"
    And I am on new child page
    Then I should see "Arabic Translated Name" translated
    And I should not see "Russian Translated Name" translated
