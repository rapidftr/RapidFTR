Feature: So that I can only see children I have permission to see
  As a user of the website
  I want my searches to return child records according to my permissions level

  Background:
    Given a user "mary" with password "123" and "limited" permission
    And a user "ted" with password "123" and "unlimited" permission
    And the following children exist in the system:
      | name   | created_by |
      | Willis | mary       |
      | Willas | mary       |
      | Willus | ted        |

  Scenario Outline:
    Given I am logged in as "<user>"
    And I am on the child search page

    When I fill in "Will" for "query"
    And I press "Search"

    Then I should be on the child search results page
    And I should see following visibility of children in search results:
      | name   | visibility        |
      | Willis | <Willis_visible?> |
      | Willas | <Willas_visible?> |
      | Willus | <Willus_visible?> |

  Examples:
    | user | Willis_visible? | Willas_visible? | Willus_visible? |
    | mary | Yes             | Yes             | No              |
    | ted  | Yes             | Yes             | Yes             |