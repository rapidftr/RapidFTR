Feature:
  So that we can keep track of children that are found in the field, a user should be able to go to a website and upload
  basic information about the lost child.

  Scenario: creating a child record
    Given I am logged in
    And I am on children listing page
    And I follow "Register New Child"

    When I fill in "Jorge Just" for "Name"
    And I fill in "27" for "Date of Birth / Age"
    And I select "Male" from "Sex"
    And I fill in "London" for "Nationality"
    And I fill in "Haiti" for "Birthplace"
    And I attach a photo "features/resources/jorge.jpg"
    And I press "Save"

    Then I should see "Child record successfully created."
    And I should see "Jorge Just"
    And I should see "27"
    And I should see "1"
    And I should see "Male"
    And I should see "London"
    And I should see "Haiti"

    When I follow "Back"

    Then I should see "View All Children"
    And I should see "Jorge Just"
    And I should see "View"

    When I follow "Jorge Just"
    Then I follow "Back"
    And I should see "View All Children"
    And I should see "Jorge Just"

    When I follow "View"
    Then I follow "Back"
    And I should see "View All Children"
    And I should see "Jorge Just"

  Scenario: create child with approximate age

    Given I am logged in
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
    And I am logged in
    And I am on new child page
    When I fill in "very tall" for "Height"
    And I press "Save"
    Then I should see "Height must be a valid number"

  @123
  Scenario: cancel button should prompt user
    Given I am logged in
    Given I am on new child page
    Then the "Discard" button presents a confirmation message
