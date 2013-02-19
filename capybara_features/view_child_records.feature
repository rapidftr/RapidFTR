Feature: So that I can filter the types of records being show when viewing search results
  As a user of the website
  I want to enter a search query in to a search box and see all relevant results
  I want to filter the search results by either all, reunited, flagged or active

  Background:
    Given I am logged in
    And I am on the children listing page

  Scenario: Checking filter by All returns all the children in the system

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |
      | jaco     | NYC                 | james    | james456     | true     | true  |
      | meredith | Austin              | james    | james123     | false    | false |

    When I am on the children listing page
    And I select "All" from "filter"
    Then I should see "andreas"
    And I should see "zak"
    And I should see "jaco"
    And I should see "meredith"

  Scenario: Checking filter by All should by default show all children in alphabetical order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |
      | andreas  | London              | zubair   | zubairlon123 |
      | zak      | London              | zubair   | zubairlon456 |
      | jaco     | NYC                 | james    | james456     |
      | meredith | Austin              | james    | james123     |

    When I am on the children listing page
    Then I should see the order andreas,jaco,meredith,zak

  Scenario: Checking filter by All shows the Order by options

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |
      | andreas  | London              | zubair   | zubairlon123 |
      | zak      | London              | zubair   | zubairlon456 |
      | jaco     | NYC                 | james    | james456     |
      | meredith | Austin              | james    | james123     |

    When I am on the children listing page
    Then I should see "Order by"
    And I should see "Most recently created"

  @javascript
  Scenario: Checking filter by All and then ordering by most recently added returns all the children in order of most recently added

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | created_at             |
      | andreas  | London              | zubair   | zubairlon123 | 2004-02-03 04:05:06UTC |
      | zak      | London              | zubair   | zubairlon456 | 2003-02-03 04:05:06UTC |
      | jaco     | NYC                 | james    | james456     | 2002-02-03 04:05:06UTC |
      | meredith | Austin              | james    | james123     | 2001-02-03 04:05:06UTC |

    When I am on the children listing page
    Then I select "Most recently created" from "order_by"
    Then I should see the order andreas,zak,jaco,meredith

  Scenario: Checking filter by All sand then ordering by Name should return all the children in alphabetical order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    |
      | andreas  | London              | zubair   | zubairlon123 |
      | zak      | London              | zubair   | zubairlon456 |
      | jaco     | NYC                 | james    | james456     |
      | meredith | Austin              | james    | james123     |

    When I am on the children listing page
    And I select dropdown option "Most recently created"
    Then I select dropdown option "Name"
    Then I should see the order andreas,jaco,meredith,zak

    @javascript
  Scenario: Checking filter by Reunited returns all the reunited children in the system

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |
      | jaco     | NYC                 | james    | james456     | true     | true  |
      | meredith | Austin              | james    | james123     | false    | false |

    And I select "Reunited" from "filter"
    Then I should see "andreas"
    And I should see "jaco"

  @javascript
  Scenario: Checking filter by Reunited shows the Order by options

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | true | DateTime.new(2003,2,3,4,5,6) |

    And I select "Reunited" from "filter"
    Then I should see "Order by"
    And I should see "Most recently reunited"

  @javascript
  Scenario: Checking filter by Reunited should by default show the records ordered alphabetically

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  | reunited_at                  |
      | andreas  | London              | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | true     | false | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | true     | false | DateTime.new(2003,2,3,4,5,6) |

    And I select "Reunited" from "filter"
    Then I should see the order andreas,jaco,meredith,zak

  @javascript
  Scenario: Checking filter by Reunited and then selecting order by most recently reunited children returns the children in the order of most recently reunited

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  | reunited_at                  |
      | andreas  | London              | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | true     | false | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | true     | false | DateTime.new(2003,2,3,4,5,6) |

    And I select "Reunited" from "filter"
    And I select "Most recently reunited" from "order_by"
    Then I should see the order zak,meredith,jaco,andreas

  @javascript
  Scenario: Checking filter by Reunited by name should show records in alphabetical order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  | reunited_at                  |
      | andreas  | London              | zubair   | zubairlon123 | true     | true  | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | true     | false | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true  | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | true     | false | DateTime.new(2003,2,3,4,5,6) |

    And I select "Reunited" from "filter"
    And I select "Most recently reunited" from "order_by"
    And I select "Name" from "order_by"
    Then I should see the order andreas,jaco,meredith,zak

  @javascript
  Scenario: Checking filter by Flagged returns all the flagged children in the system

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |   reunited_at                  | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |   DateTime.new(2001,2,3,4,5,6) | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |   DateTime.new(2004,2,3,4,5,6) | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true  |   DateTime.new(2002,2,3,4,5,6) | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | false |   DateTime.new(2003,2,3,4,5,6) | DateTime.new(2003,2,3,4,5,6) |

    And I select "Flagged" from "filter"
    Then I should see "zak"
    And I should see "jaco"

  @javascript
  Scenario: Checking filter by Flagged shows the Order by options

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | true | DateTime.new(2003,2,3,4,5,6) |

    And I select "Flagged" from "filter"
    Then I should see "Order by"
    And I should see "Most recently flagged"

  @javascript
  Scenario: Checking filter by Flagged returns all the flagged children in the system by order of most recently flagged

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | true | DateTime.new(2003,2,3,4,5,6) |

    And I select "Flagged" from "filter"
    And I select "Most recently flagged" from "order_by"
    Then I should see the order zak,meredith,jaco,andreas

  @javascript
  Scenario: Checking filter by Flagged and then ordering by name returns the flagged children in alphabetical order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | true | DateTime.new(2003,2,3,4,5,6) |

    And I select "Flagged" from "filter"
    And I select "Name" from "order_by"
    Then I should see the order andreas,jaco,meredith,zak

  @javascript
  Scenario: Checking filter by Flagged and ordering by most recently flagged returns the children in most recently flagged order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | flagged_at                   |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true | DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | true | DateTime.new(2003,2,3,4,5,6) |

    And I select "Flagged" from "filter"
    And I select "Name" from "order_by"
    And I select "Most recently flagged" from "order_by"
    Then I should see the order zak,meredith,jaco,andreas

  @javascript
  Scenario: Checking filter by Active returns all the children who are not reunited in the system

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |
      | jaco     | NYC                 | james    | james456     | true     | true  |
      | meredith | Austin              | james    | james123     | false    | false |

    When I go to the children listing page
    Then I should see "zak"
    And I should see "meredith"

  @javascript
  Scenario: Checking filter by Active should by default show the records ordered alphabetically

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |
      | jaco     | NYC                 | james    | james456     | true     | true  |
      | meredith | Austin              | james    | james123     | false    | false |

    When I go to the children listing page
    Then I should see the order meredith,zak

  @javascript
  Scenario: Checking filter by Active shows the Order by options

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag |
      | andreas  | London              | zubair   | zubairlon123 | true     | true |
      | zak      | London              | zubair   | zubairlon456 | false    | true |
      | jaco     | NYC                 | james    | james456     | true     | true |
      | meredith | Austin              | james    | james123     | false    | true |

    When I go to the children listing page
    Then I should see "Order by"
    And I should see "Most recently created"

  @javascript
  Scenario: Checking filter by Active and then ordering by most recently created returns the children in the order of most recently created

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag | created_at             |
      | andreas  | London              | zubair   | zubairlon123 | true     | true | 2004-02-03 04:05:06UTC |
      | zak      | London              | zubair   | zubairlon456 | false    | true | 2003-02-03 04:05:06UTC |
      | jaco     | NYC                 | james    | james456     | false    | true | 2002-02-03 04:05:06UTC |
      | meredith | Austin              | james    | james123     | false    | true | 2001-02-03 04:05:06UTC |

    When I go to the children listing page
    And I select "Most recently created" from "order_by"
    Then I should see the order zak,jaco,meredith

  @javascript
  Scenario: Checking filter by Active and order by name should return the children in alphabetical order

    Given the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false |
      | zak      | London              | zubair   | zubairlon456 | false    | true  |
      | jaco     | NYC                 | james    | james456     | false    | true  |
      | meredith | Austin              | james    | james123     | false    | false |

    When I go to the children listing page
    And I select "Most recently created" from "order_by"
    And I select "Name" from "order_by"
    Then I should see the order jaco,meredith,zak
