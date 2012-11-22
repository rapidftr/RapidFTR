Feature:
  So that we can keep track of children that are found in the field, a user should be able to go to a website and upload
  basic information about the lost child.

#  Story #622: Advanced Search - Search by User & Record Details
  Scenario:  Check that child record contains logged in user full name in created_by_full_name

    Given "jr_test" logs in with "Register Child" permissions
    And someone has entered a child with the name "kiloutou"
    Then I should see "Child record successfully created."
    And the field "created_by" of child record with name "kiloutou" should be "jr_test"
    And the field "created_by_full_name" of child record with name "kiloutou" should be "jr_test"

  Scenario: create child with approximate age

    Given I am logged in as a user with "Register Child" permission
    And I am on new child page

    When I fill in the basic details of a child
    And I press "Save"

    Then I should see "Child record successfully created."

  @javascript
  Scenario: create child with numeric custom field
    Given the following form sections exist in the system:
        | name | unique_id | editable | order | enabled |
        | Basic details | basic_details | false | 1 | true |
    And the "basic_details" form section has the field "Height" with field type "numeric_field"
    And I am logged in as a user with "Register Child" permission
    And I am on new child page
    When I fill in "very tall" for "Height"
    And I press "Save"
    Then I should see "Height must be a valid number"

  @123
  Scenario: cancel button should prompt user
    Given I am logged in as a user with "Register Child" permission
    Given I am on new child page
    Then the "Discard" button presents a confirmation message

  Scenario: List on children link should link to Children List page
    Given I am logged in as a user with "Register Child" permission
    And I am on new child page
    When I follow "List of Children"
    Then I should be on children listing page

