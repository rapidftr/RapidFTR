Feature:
  Features related to enquiry record, including view enquiry record, create enquiry record

  Background:
    Given the following forms exist in the system:
      | name      |
      | Enquiries |
      | Children  |
    And the following form sections exist in the system on the "Enquiries" form:
      | name             | unique_id        | editable | order | visible | perm_enabled |
      | Enquiry Criteria | enquiry_criteria | false    | 1     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name             | type       | display_name  | editable |
      | enquirer_name_ct | text_field | Enquirer Name | false    |
      | child_name_ct    | text_field | Child's Name  | false    |
      | location_ct      | text_field | Location      | false    |

  Scenario: Adding/Viewing Enquiry Record
    Given I am logged in as a user with "Create Enquiry,View Enquiries" permissions
    When I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "Jorge Just"
    And I fill in "Location" with "Kampala"
    And I press "Save"

    Then I should see "Charles"
    And I should see "Jorge Just"
    And I should see "Kampala"

  Scenario: Enquiries link should link to Enquiries list page
    Given I am logged in as a user with "Create Enquiry,View Enquiries" permissions
    When I follow "ENQUIRIES"
    Then I should be on "enquiries listing page"

  @javascript
  Scenario: Enquiries listing page should show enquiries
    Given I am logged in as an admin
    And I follow "System Settings"
    And I follow "Highlight Fields"
    And I follow "Enquiries"
    And I click text "add"
    And I select menu "Enquiry Criteria"
    And I select menu "Enquirer Name"
    Then I logout
    And I am logged in as a user with "Create Enquiry,View Enquiries" permissions
    And the following enquiries exist in the system:
      | enquirer_name_ct | child_name_ct | location_ct |
      | bob              | bob chulu     | kampala     |
      | john             | john doe      | gulu        |
      | jane             | jane doe      | adjumani    |
    And I am on the "enquiries listing page"
    Then I should see "bob"
    And I should see "john"
    And I should see "jane"

  @javascript
  Scenario: View potential Matches for enquiry
    Given the following children exist in the system:
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
    And I am logged in as a user with "Create Enquiry,View Enquiries" permissions
    When I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "John Doe"
    And I fill in "Location" with "London"
    And I press "Save"
    Then I follow "Potential Matches"
    And I should see "2" children on the page

  Scenario: View list of enquiries with potential matches
    Given the following children exist in the system:
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
      | enquirer_name_ct | child_name_ct | location_ct |
      | bob              | bob chulu     | kampala     |
      | john             | john doe      | gulu        |
      | jane             | jane doe      | adjumani    |
    And I am logged in as a user with "View Enquiries" permissions
    When I follow "2 Enquiries with potential matches"
    Then I should see "Enquiries with potential matches"
    And I should see "2" enquiries on the page