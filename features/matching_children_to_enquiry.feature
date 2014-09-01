Feature: So that administrators and workers can efficiently match children to enquiries

  Background:
    Given I am logged in as an admin
    And the following forms exist in the system:
      | name      |
      | Enquiries |
      | Children  |
    And the following form sections exist in the system on the "Children" form:
      | name           | unique_id      | editable | order | visible | perm_enabled |
      | Basic Identity | basic_identity | false    | 1     | true    | true         |
    And the following form sections exist in the system on the "Enquiries" form:
      | name          | unique_id     | editable | order | visible | perm_enabled |
      | Basic details | basic_details | false    | 1     | true    | true         |
    And the following fields exists on "basic_identity":
      | name           | type       | display_name   | editable |
      | name           | text_field | Name           | true     |
      | nick_name      | text_field | Nick Name      | true     |
    And the following fields exists on "basic_details":
      | name           | type       | display_name   | editable | searchable |
      | child_name     | text_field | Name           | false    | false      |
      | enquirer_name  | text_field | Enquirer Name  | true     | true       |

  @javascript
  @search
  Scenario: Marking fields as searchable changes search results
    Given the following enquiries exist in the system:
      | child_name    | enquirer_name | _id | created_at             | posted_at              | created_by |
      | bob           | nick          | 1   | 2011-06-22 02:07:51UTC | 2011-06-22 02:07:51UTC | Sanchari   |
    And the following children exist in the system:
      | name   | nick_name |
      | bob    | bobby     |
    When I am on the enquiry page for "1"
    And I follow "Potential Matches"
    Then I should see "0" children on the page
    When I follow "FORMS"
    And I follow "Enquiries"
    And I follow "Basic details"
    And I mark "child_name" as searchable
    When I am on the enquiry page for "1"
    And I follow "Potential Matches"
    Then I should see "1" children on the page
