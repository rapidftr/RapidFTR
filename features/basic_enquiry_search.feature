Feature:
  Features related to enquiry search

  Background:
    Given the following forms exist in the system:
      | name      |
      | Enquiries |
    And the following form sections exist in the system on the "Enquiries" form:
      | name             | unique_id        | editable | order | visible | perm_enabled |
      | Enquiry Criteria | enquiry_criteria | false    | 1     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name             | type       | display_name  | editable | matchable  | highlighted |
      | enquirer_name    | text_field | Enquirer Name | false    | true       | true        |
    And Solr is setup

  Scenario: Searching for an enquiry given a highlighted field
    Given the following enquiries exist in the system:
      | enquirer_name   |
      | Willis          |
      | Will            |
    And I am logged in as a user with "View Enquiries" permissions
    When I fill in "query" with "Will"
    And I select dropdown option "Enquiry"
    And I press "Go"
    Then I should see "Willis" in the search results

  Scenario: Searching for an enquiry given a unique id
    Given the following enquiries exist in the system:
      | unique_identifier | enquirer_name | _id |
      | abc123            | Willis        | 567 |
    And I am logged in as a user with "View Enquiries" permissions
    When I fill in "query" with "abc123"
    And I select dropdown option "Enquiry"
    And I press "Go"
    Then I should be on the enquiry page for "567"

  Scenario: Searching for an enquiry given a short id
    Given the following enquiries exist in the system:
      | unique_identifier  | enquirer_name   | _id        |
      | abcdef123456       | Willis          | 1234567890 |
    And I am logged in as a user with "View Enquiries" permissions
    When I fill in "query" with "f123456"
    And I select dropdown option "Enquiry"
    And I press "Go"
    Then I should be on the enquiry page for "1234567890"

  Scenario: Search parameters are displayed in the search results
    Given the following enquiries exist in the system:
      | unique_identifier  | enquirer_name   |
      | abcdef123456       | Willis          |
      | 09876lkjhg         | Will            |
    And I am logged in as a user with "View Enquiries" permissions
    When I fill in "query" with "Will"
    And I select dropdown option "Enquiry"
    And I press "Go"
    Then I should be on search results page
    And the "query" field should contain "Will"
    And the "search_type" dropdown should have "Enquiry" selected
