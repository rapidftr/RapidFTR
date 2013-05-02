Feature: Ensure translations

  Background:
    Given I am logged in as a user with "Admin" permission
    Given the following translations exist:
      | locale | key        | value                   |
      | ar     | xxxx       | Arabic Translated Name  |
      | en     | xxxx       | English Translated Name |
      | ru     | yyyy       | Whatever in Russian     |
      | fr     | ffff       | Whatever in French      |
      | zh     | cccc       | Whatever in Chinese     |

  Scenario: Field label translations
    When I set the system language to "English"-"en"
    And I set the user language to "العربية"-"ar"
    Then I should see "Arabic Translated Name" translated

  Scenario: Field label translation missing
    When I set the system language to "العربية"-"ar"
    And I set the user language to "Русский"-"ru"
    Then I should see "Arabic Translated Name" translated
    And I logout

  Scenario: Field label translation missing in system and user locale
    When I set the system language to "中文"-"zh"
    And I set the user language to "Français"-"fr"
    Then I should see "English Translated Name" translated
    And I logout

  Scenario: View system language changed by Admin
  As an Admin I change the system language
  So that when I login as a system user I can view the app in the changed language

    When I set the system language to "العربية"-"ar"
    And  I logout as "Admin"

    Given an user "jerry" with password "123"
    When I fill in "jerry" for "user_name"
    And I fill in "123" for "password"
    And I select "Log In" for language change

    Then I should see my system language as "العربية"-"ar"

  Scenario:Show form fields on the edit form page in the System language

    When I set the system language to "العربية"-"ar"
    And I set the user language to "English"-"en"
    And I am on the form section page
    And I follow "Basic Identity"

    Then I should see "الإسم "
    And I should see "الوصف "
    And I should see "نص للمساعدة "
