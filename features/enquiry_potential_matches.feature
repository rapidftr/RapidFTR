Feature:
  Features related to handling potential matches on an enquiry record

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
  Scenario: View potential Matches for enquiry
    Given I am logged in as a user with "Create Enquiry,View Enquiries" permissions
    When I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "John Doe"
    And I fill in "Location" with "London"
    And I press "Save"
    Then I follow "Matches"
    And I should see "2" children on the page

  Scenario: View list of enquiries with potential matches
    Given I am logged in as a user with "View Enquiries" permissions
    When I follow "2 Enquiries with potential matches"
    Then I should see "Enquiries with potential matches"
    And I should see "2" enquiries on the page

  @javascript
  Scenario: Mark a child record as not a match for particular enquiry
    Given I am logged in as an admin
    And I follow "System Settings"
    And I follow "Highlight Fields"
    And I follow "Children"
    And I click text "add"
    And I select menu "Child Name"
    And I click text "add"
    And I select menu "Birthplace"
    Then I logout
    And I am logged in as a user with "View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I follow "2 Enquiries with potential matches"
    And I follow "20e3fe"
    And I follow "Matches"
    Then I should see "John"
    Then I should see "Doe"
    When I mark child with unique_id "zubairlon233" as not matching
    Then I should not see "John"

  @javascript
  Scenario: Confirm a record as a match
    Given I am logged in as an admin
    And I follow "System Settings"
    And I follow "Highlight Fields"
    And I follow "Children"
    And I click text "add"
    And I select menu "Child Name"
    And I click text "add"
    And I select menu "Birthplace"
    Then I logout
    And I am logged in as a user with "View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I follow "2 Enquiries with potential matches"
    And I follow "20e3fe"
    And I follow "Matches"
    Then I should see "John"
    Then I should see "Doe"
    When I mark child with unique_id "zubairlon233" as not matching
    Then I should not see "John"

  Scenario: Confirm a potential match should be reflected in the UI
    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | birthplace |
      | jerry    | London              | zubair   | zubairlon456 | kampala    |
    And the following enquiries exist in the system:
      | enquirer_name_ct | child_name_ct | location_ct | _id    | unique_identifier |
      | jerry            | jerry chulu   | kampala     | 3a0bed | 3a0bed            |
    And I am logged in as a user with "View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I am on the enquiry page for "3a0bed"
    Then I should not see "Confirmed Matches"
    When I follow "Matches"
    And I confirm child match with unique_id "zubairlon456"
    Then I should see "Confirmed Matches"
    And I should not see "Confirm as Match"
    And I should not see a 'Mark as not matching' link for "zubairlon456"
    And I should see "Confirmed Matches: rlon456"
    When I follow "rlon456"
    Then I should see "Confirmed Matches: 3a0bed"

  Scenario: Undo a potential match confirmation
    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | birthplace |
      | jerry    | London              | zubair   | zubairlon456 | kampala    |
    And the following enquiries exist in the system:
      | enquirer_name_ct | child_name_ct | location_ct | _id    | unique_identifier |
      | jerry            | jerry chulu   | kampala     | 3a0bed | 3a0bed            |
    And I am logged in as a user with "View Enquiries,Update Enquiry,View And Search Child,Edit Child" permissions
    When I am on the enquiry page for "3a0bed"
    And I follow "Matches"
    And I confirm child match with unique_id "zubairlon456"
    And I follow "Undo Confirmation"
    Then I should not see "Confirmed Matches"
