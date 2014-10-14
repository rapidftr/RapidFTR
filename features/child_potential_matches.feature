Feature:
  Features related to handling potential matches on a child record

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
      | enquirer_name_ct | text_field | Enquirer Name | false    | true       |
      | child_name_ct    | text_field | Child's Name  | false    | true       |
      | location_ct      | text_field | Location      | false    | true       |
    And the following form sections exist in the system on the "Children" form:
      | name             | unique_id        | editable | order | visible | perm_enabled |
      | Basic Identity   | basic_identity   | false    | 1     | true    | true         |
    And the following fields exists on "basic_identity":
      | name             | type       | display_name  | editable |
      | name             | text_field | Child Name    | false    |
      | birthplace       | text_field | Birthplace    | false    |
    And the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | birthplace |
      | John     | London              | zubair   | zubairlon233 | nairobi    |
      | Doe      | London              | zubair   | zubairlon423 | bengal     |
      | shaikh   | NYC                 | james    | james423     | kerala     |
      | marylyn  | Austin              | james    | james124     | cairo      |
      | jacklyn  | Austin              | james    | james125     | cairo      |
      | imran    | Austin              | james    | james126     | cairo      |
      | sachin   | Austin              | james    | james127     | cairo      |
      | virat    | Austin              | james    | james128     | cairo      |
      | gambhir  | Austin              | james    | james129     | cairo      |
      | mahendra | Austin              | james    | james130     | cairo      |
      | pragyan  | Austin              | james    | james148     | cairo      |
    And the following enquiries exist in the system:
      | enquirer_name_ct | child_name_ct | location_ct | _id      |
      | bob              | bob chulu     | kampala     |  1a0ced  |
      | john             | john doe      | gulu        |  20e3fe  |
      | jane             | jane doe      | adjumani    |  3d5elk  |


  @javascript
  Scenario: Reunited Child should show reunited enquiries under matches
    Given I am logged in as a user with "Create Enquiry,View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I follow "Enquiries"
    And I follow "20e3fe"
    And I follow "Matches"
    And I confirm child match with unique_id "zubairlon233"
    And I should see "Confirmed Matches"
    And I follow "rlon233"
    And I click the "Mark as Reunited" link
    And I fill in "child_reunited_message" with "Testing"
    And I click the "Reunite" button
    And I follow "Matches"
    Then I should see "Reunited Matches"
    And I should see "20e3fe"
    And I should not see "Confirm as Match"

  @javascript
  Scenario: Reunited Child should not show confirmation links for reunited enquiries under matches
    Given I am logged in as a user with "Create Enquiry,View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I follow "Enquiries"
    And I follow "20e3fe"
    And I follow "Matches"
    And I confirm child match with unique_id "zubairlon233"
    And I should see "Confirmed Matches"
    And I follow "rlon233"
    And I click the "Mark as Reunited" link
    And I fill in "child_reunited_message" with "Testing"
    And I click the "Reunite" button
    And I follow "Matches"
    Then I should see "Reunited Matches"
    And I should see "20e3fe"
    And I should not see "Confirm as Match"
    And I should not see "Undo Confirmation"
