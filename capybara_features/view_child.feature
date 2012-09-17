Feature: So that I can only see children I have permission to see
  As a user of the website
  I want to forbid limited user to see child created by others

  Background:
    Given a user "mary" with password "123" and "limited" permission
    And a user "ted" with password "123" and "unlimited" permission
    And the following children exist in the system:
      | name   | created_by |
      | Willas | mary       |
      | Willis | ted        |

  Scenario Outline:
    Given I am logged in as "<user>"
    When I go to the child record page for "<child>"
    Then I am on <result_page>

  Examples:
    | user | child  | result_page                        |
    | mary | Willas | the child record page for "Willas" |
    | mary | Willis | the home page                      |
    | ted  | Willas | the child record page for "Willas" |
    | ted  | Willis | the child record page for "Willis" |