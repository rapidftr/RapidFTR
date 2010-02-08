Feature: As a user, when a child offers information on the members of his family, I should be able to add those members to his record
  @wip
  Scenario: Uncles names should be stored
    Given the database is empty
    Given I am on the new child page
    When I fill in "Jorge Just" for "name"

    Then I fill in "Mary" for "mothers name"
    And I check "Mother alive"
    Then I fill in "John" for "fathers name"
    And I check "Father alive"
    Then I fill in "Victoria" for "siblings"
    Then I fill in "Paul" for "Uncles(s)"
    Then I fill in "Elizabeth" for "Aunt(s)"
    Then I fill in "James" for "Cousin(s)"
    Then I fill in "Claudia" for "Neighbour(s)"
    Then I fill in "Blah" for "Others"
    Then I check "Married?"
    Then I fill in "Matilda" for "spouse/partner name"

    And I click "Create"

    Then I should see "Mary"
    Then I should see "John"
    Then I should see "Victoria"
    Then I should see "Paul"
    Then I should see "Elizabeth"
    Then I should see "James"
    Then I should see "Claudia"
    Then I should see "Blah"
    Then I should see "Matilda"


# Scenario: Should be able to select whether a child wants to reunite with family members

#     And I check <relationship>
#    Examples:
#   |relationship|
#  |reunite with mother?|
# |reunite with father?|
#     |reunite with uncle?|
#        |reunite with aunt?|
#       |reunite with cousin?|
#      |reunite with neighbour?|
#     |reunite with other?|

