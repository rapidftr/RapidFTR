@wip

# this test is no more valid as this the entire UI is changed
Feature: So that admin can see Manage Form Sections Page

  Background:
    Given I am logged in as an admin
    And the following form sections exist in the system:
      | name              | description                   | unique_id         | order | perm_enabled |
      | Basic Identity    | Basic identity about a child  | basic_details     | 1     | true         |
      | Family Details    | Details of the child's family | family_details    | 2     | false        |
      | Care Arrangements |                               | care_arrangements | 3     | false        |
    And I follow "FORMS"

  @javascript
  Scenario: Admins should see correct re-ordering links for each section
    Then I should see the "Basic Identity" section without any ordering links
    And I should see the "Basic Identity" section without an enabled checkbox
    And I should see the "Care Arrangements" section with an enabled checkbox
    And I should see "Family Details" with order of "2"
    And I should see "Care Arrangements" with order of "3"

  Scenario: Admins should see a back button
    Then I should see "Back"
