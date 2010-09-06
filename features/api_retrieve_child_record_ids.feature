Feature: So that an API client can pull down child records one per request
  as an API user,
  I want to hit a URI that returns me a list of CouchDB Record Ids and Revision Ids for each child record


  Scenario: Only Id and Revision properties are returned for each child record
    Given the following children exist in the system:
      | name |
      | Tom  |
      | Kate |
      | Jess |
    Given I am logged in
    When I make a request for all child Ids
    Then I receive a JSON list of elements with Id and Revision

