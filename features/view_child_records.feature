Feature: So that I can filter the types of records being show when viewing search results
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results
  I want to filter the search results by either all, reunited, flagged or active

  Background:
    Given I am logged in
    And I am on the children listing page

  Scenario: Checking to verify there is a filter box 
    Then I should see "Filter by status"
    And I should see "All"
    And I should see "Reunited"
    And I should see "Flagged"
    And I should see "Active"
  
  Scenario: Checking filter by All returns all the children in the system
    
    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | false |
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  |
      | jaco	  | NYC		                | james    | james456     | true     | true  |
      | meredith| Austin	              | james    | james123     | false    | false |

    When I follow "All"
    Then I should see "andreas"
    And I should see "zak"
    And I should see "jaco"
    And I should see "meredith" 
    
  Scenario: Checking filter by Reunited returns all the reunited children in the system

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | false |
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  |
      | jaco	  | NYC		                | james    | james456     | true     | true  |
      | meredith| Austin	              | james    | james123     | false    | false |

    When I follow "Reunited"
    Then I should see "andreas"
    And I should see "jaco"
    
  Scenario: Checking filter by Flagged returns all the flagged children in the system

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | false |
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  |
      | jaco	  | NYC		                | james    | james456     | true     | true  |
      | meredith| Austin	              | james    | james123     | false    | false |

    When I follow "Flagged"
    Then I should see "zak"
    And I should see "jaco"
    
  Scenario: Checking filter by Active returns all the children who are not reunited in the system

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | false |
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  |
      | jaco	  | NYC		                | james    | james456     | true     | true  |
      | meredith| Austin	              | james    | james123     | false    | false |

    When I follow "Active"
    Then I should see "zak"
    And I should see "meredith"    
    