Feature:

  As an API user
  I want to hit a URI that gives me all published form sections
  So that an API client can have all fields related to entering information

  Background:
    Given a registration worker "tim" with a password "123"
    And I login as tim with password 123 and imei 10001

  Scenario: A logged in API user should be able to retrieve all published form sections
    When I send a GET request to "/api/form_sections"
    Then the JSON response should have "Enquiries"
    And the JSON response should have "Children"
    And the JSON at "Children" should be an array
    And the JSON at "Children/0" should have the following:
      | order        | 1                |
      | editable     | true             |
      | visible      | true             |
      | unique_id    | "basic_identity" |

      | name/en        | "Basic Identity"                                                       |
      | description/en | "Basic identity information about a separated or unaccompanied child." |

      | fields/0/display_name/en  | "Name"       |
      | fields/0/type             | "text_field" |
      | fields/0/visible          | true         |
      | fields/0/name             | "name"       |
      | fields/0/highlight_information/highlighted | true |
      | fields/0/highlight_information/order       | 1    |
