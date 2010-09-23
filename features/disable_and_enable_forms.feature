Feature: Disable and enable forms
  In order to customise the view
  As an admin user
  wants to be able to enable and disable particular forms

  Background:
    Given the following form sections exist in the system:
      | name              | unique_id         | editable | order | enabled |
      | Basic details     | basic_details     | false    | 1     | true    |
      | Caregiver details | caregiver_details | true     | 2     | false   |

  Scenario Outline: Register new disable_and_enable_forms
    Given I am logged in as an admin
    And I am on the form section page
    When I check "sections_basic_details"
    Then the checkbox with id "<checkbox_id>" <has_this_value>
  Examples:
    | name              | order | unique_id         | enabled | checkbox_id                | has_this_value        |
    | Basic details     | 1     | basic_details     | true    | sections_basic_details     | should not be checked |
    | Caregiver details | 2     | caregiver_details | false   | sections_caregiver_details | should not be checked |


  Scenario Outline: Should enable selected forms
    Given I am logged in as an admin
    And I am on the form section page
    Then I should see the text "Disabled" in the enabled column for the form section "caregiver_details"
    When I check "sections_caregiver_details"
    And I press "Enable"
    Then I should see the text "Enabled" in the enabled column for the form section "caregiver_details"
    And the checkbox with id "<checkbox_id>" <has_this_value>
  Examples:
    | checkbox_id                | has_this_value        |
    | sections_basic_details     | should not be checked |
    | sections_caregiver_details | should not be checked |

 
