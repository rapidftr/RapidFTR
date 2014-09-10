Feature: Test weather each enquiry has a proper change log attached to it.

  Background:
    Given the following forms exist in the system:
      | name      |
      | Enquiries |
      | Children  |
    And the following form sections exist in the system on the "Enquiries" form:
      | name             | unique_id        | editable | order | visible | perm_enabled |
      | Enquiry Criteria | enquiry_criteria | false    | 1     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name             | type       | display_name  | editable | matchable |
      | enquirer_name_ct | text_field | Enquirer Name | false    | true      |
      | child_name_ct    | text_field | Child's Name  | false    | true      |
      | location_ct      | text_field | Location      | false    | true      |

  @javascript
  Scenario: Validate presence of changelog button and viewing changelog history of an enquiry

    Given "bob" logs in with "Create Enquiry,View Enquiries,Update Enquiry" permissions
    When I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "Jorge Just"
    And I fill in "Location" with "Kampala"
    And I press "Save"
    When I follow "Change Log" span
    Then I should see change log of creation by user "bob"
    And I follow "Back"
    Then I follow "Edit" span
    And I fill in "Location" with "India"
    And I submit the form
    And I follow "Change Log" span
    Then I should see change log for changing value of field "Location" from "Kampala" to value "India" by "bob"