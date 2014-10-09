@search
Feature:
  Features related to enquiry record, including view enquiry record, view photo, view audio, create enquiry record and filter enquiry record etc.

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
    And the following enquiries exist in the system:
      | unique_identifier | reunited | enquirer_name_ct | _id         |
      | reunited          | true     | reunited         | reunited    |
      | confirmed         | false    | confirmed        | confirmed   |
      | has_mathces       | false    | has_matches      | has_matches |
    Given I am logged in as a user with "View Enquiries" permission
    And I am on the "enquiries listing page"

  Scenario: Checking filter by All returns all the enquiries in the system
    When I select "All" from "filter"
    Then I should see "reunited"
    And I should see "confirmed"
    And I should see "has_matches"

  Scenario: Checking filter by Reunited returns all reunited enquiries
    When I select "Reunited" from "filter"
    Then I should see "reunited"

  Scenario: Checking filter by Has Matches shows the Order by options
    Given there is a potential match for enquiry 'has_matches'
    When I select "Has Matches" from "filter"
    Then I should see "has_matches"

  Scenario: Checking filter by Has Confirmed Match shows the Order by options
    Given there is a confirmed potential match for enquiry 'has_matches'
    When I select "Has Confirmed Match" from "filter"
    Then I should see "confirmed"
