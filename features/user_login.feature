Feature: As an user, I should be able to log in.

  Scenario: To check that a user can log in
    Given a user "Harry" with a password "123"
    And I am on the login page

    When I fill in "Harry" for "user name"
    And I fill in "123" for "password"
    And I press "Log in"

    Then I should see "Hello harry"
    And I should be on the home page

  Scenario: To check that a logged in user doesn't see the login page

    Given I am logged in

    When I go to the login page

    Then I should see "View child listing"
    And I should not see "Hello mary"

  Scenario: User does not exist

    Given I am on the login page

    When I fill in "Harry" for "user name"
    And I fill in "123" for "password"
    And I press "Log in"

    Then I should see "Invalid credentials. Please try again!"

  Scenario: User enters the wrong password

    Given a user "Harry" with a password "123"
    And I am on the login page

    When I fill in "Harry" for "user name"
    And I fill in "1234" for "password"
    And I press "Log in"

    Then I should see "Invalid credentials. Please try again!"

  Scenario: Disabled user can't log in

    Given a user "Harry" with a password "123"
    And user "Harry" is disabled
    And I am on the login page

    When I fill in "Harry" for "user name"
    And I fill in "123" for "password"
    And I press "Log in"

    Then I should see "Invalid credentials. Please try again!"

  @allow-rescue
  Scenario:User session should be destroyed when a user logs out

    Given I am logged in

    When I follow "logout"

    Then I should be on the login page

    When I go to new child page
    Then I should be on the login page

  Scenario: I should not see 'Logged in as' if I'm logged out

    Given there is a User
    And I am logged out     

    Then I should not see "Logged in as"

  Scenario: I should see the Contact & Help page even when I'm not logged in
	Given the following admin contact info:
      | key | value |
      | name | John Smith |
      | id | administrator |
    And I am on the login page
	Then I should see "Contact & Help"
	When I follow "Contact & Help"
    Then I should be on the administrator contact page