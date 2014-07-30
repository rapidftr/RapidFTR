Feature: As an user I should not see disabled forms when adding new child

  Scenario: User creates new child record and does not see disabled forms

    Given I am logged in as a user with "Register Child" permission
    And the following form sections exist in the system:
      | name   | description | unique_id | order | visible |
      | Basic Details | Basic details about a child | basic_details | 1 | true |
      | Family Details   | Details of the child's family | family_details | 2 | true |
      | Caregiver Details   |  | caregiver_details | 3 | true |
      | Disabled |  | disabled_details | 4 | false |
    And I am on children listing page
    And I follow "Register New Child"

    Then I should see the "Basic Details" tab
    And I should see the "Family Details" tab
    And I should see the "Caregiver Details" tab
    And I should not see the "Disabled Details" tab
