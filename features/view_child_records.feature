Feature: So that I can filter the types of records being show when viewing search results
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results
  I want to filter the search results by either all, reunited, flagged or active

  Background:
    Given I am logged in
    And I am on the children listing page

  Scenario: Checking to verify there is a filter box 
    Then I should see "Filter by:"
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
    
  Scenario: Checking filter by Flagged returns all the flagged children in the system by order of most recently flagged

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | flagged_at                  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | false    | true  | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Flagged"
    Then I should see the order zak,meredith,jaco,andreas
    
  Scenario: Checking filter by Flagged shows the Order by options
  
    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | flagged_at                  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | false    | true  | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Flagged"
    Then I should see "Order by"
    And I should see "Most recently flagged"
    
  Scenario: Checking filter by Flagged and then ordering by name returns the flagged children in alphabetical order

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | flagged_at                  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | false    | true  | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Flagged"
    And I follow "Name"
    Then I should see the order andreas,jaco,meredith,zak

  Scenario: Checking filter by Reunited shows the Order by options

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | flagged_at                  |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | false    | true  | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | false    | true  | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Reunited"
    Then I should see "Order by"
    And I should see "Most recently reunited"

  Scenario: Checking filter by Reunited should by default show the records ordered alphabetically

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | reunited_at                 |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | true     | false | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | true     | false | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Reunited"
    Then I should see the order andreas,jaco,meredith,zak

  Scenario: Checking filter by Reunited and then selecting order by most recently reunited children returns the children in the order of most recently reunited

    Given the following children exist in the system:
      | name   	| last_known_location 	| reporter | unique_id    | reunited | flag  | reunited_at                 |
      | andreas	| London		            | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6)| 
      | zak	    | London		            | zubair   | zubairlon456 | true     | false | DateTime.new(2004,2,3,4,5,6)|
      | jaco	  | NYC		                | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6)|
      | meredith| Austin	              | james    | james123     | true     | false | DateTime.new(2003,2,3,4,5,6)|

    When I follow "Reunited"
    And I follow "Most recently reunited"
    Then I should see the order zak,meredith,jaco,andreas
