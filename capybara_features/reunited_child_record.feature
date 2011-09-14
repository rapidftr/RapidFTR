Feature: Reunited Child

  As a Field Worker
  I want to easily and visibly mark a Child Record as Reunited
  So that it is immediately apparent when a child has been reunited with her family

  Background:

   Given I am logged in
   And the following children exist in the system:
     | name   | unique_id  | reunited |
     | Will   | will_uid   | false    |
     | Will 2 | will_uid_2 | false    |
     | Fred   | fred_uid   | true     |

  Scenario: Mark a child as Reunited and check flag on the View Child Record Page
    When I am on the child record page for "Will"
     And I follow "Mark child as Reunited"
     And I fill in "child_reunited_message" with "Because I say it is reunited"
     And I click the "Reunite" button
    Then I should see "Child was successfully updated."
     And I should see 1 divs with text "Reunited" for class "reunited-message"

  Scenario: Mark a child as Not Reunited  and check flag on the View Child Record Page
    When I am on the child record page for "Fred"
     And I follow "Mark child as Not Reunited"
     And I fill in "child_reunited_message" with "Because I say it is not reunited"
     And I click the "Undo Reunite" button
    Then I should see "Child was successfully updated."
    Then I should see 0 divs with text "Reunited" for class "reunited-message"

  @wip @javascript
  Scenario: Mark a child as Reunited and check flag on the Search Results page
    When I am on the child record page for "Will"
     And I follow "Mark child as Reunited"
     And I fill in "child_reunited_message" with "Because I say it is reunited"
     And I click the "Reunite" button
    Then I should see "Child was successfully updated."
    When I am on the child search page
     And I fill in "Will" for "query"
     And I press "Search"
    Then I should be on the child search results page
     And I should see "Will" in the search results
     And I should see "Will" as reunited in the search results
     And I should see "Will 2" in the search results
#    And I sleep 45 seconds
     And I should not see "Will 2" as reunited in the search results