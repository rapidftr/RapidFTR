Feature: As an user, I should be able to log in.

  Scenario: To check that a user can log in
    Given a user "Harry" with a password "123"
    And I am on the login page

    When I fill in "User Name" with "Harry"
    And I fill in "password" with "123"
    And I press "Log in"

    Then I should see "Hello harry"
    And I should be on the home page

  Scenario: User does not exist
    Given I am on the login page
    When I fill in "User Name" with "Harry"
    And I fill in "password" with "123"
    And I press "Log in"
    Then I should see "Invalid credentials. Please try again!"

  Scenario: Logout when session destroyed in database
    Given "Lawrence" is the user
    And I am logged in as "Lawrence"
    And I have an expired session
    When I am on the home page
    Then I should be on the login page

  Scenario: User enters the wrong password
    Given a user "Harry" with a password "123"
    And I am on the login page

    When I fill in "User Name" with "Harry"
    And I fill in "password" with "1234"
    And I press "Log in"

    Then I should see "Invalid credentials. Please try again!"

  Scenario: Disabled user can't log in
    Given a user "Harry" with a password "123"
    And user "Harry" is disabled
    And I am on the login page

    When I fill in "User Name" with "Harry"
    And I fill in "password" with "123"
    And I press "Log in"

    Then I should see "Invalid credentials. Please try again!"

  @allow-rescue
  Scenario:User session should be destroyed when a user logs out
    Given I am logged in
    When I follow "Logout"
    Then I should be on the login page
    When I am on new child page
    Then I should be on the login page

  Scenario: I should not see 'Logged in as' if I'm logged out

    Given there is a User
    And I am logged out

    Then I should not see "Logged in as"

  Scenario: I should be able to change my password
    Given a user "Harry" with a password "123"
    And I am logged in as "Harry"
    And I follow "My Account"
    And I follow "Change Password"

    And I fill in "Old Password" with "123"
    And I fill in "New Password" with "456"
    And I fill in "Confirm New Password" with "456"
    And I click the "Save" button
    And I should see "Password changed successfully"

    And I follow "Logout"
    And I am on the login page
    And I fill in "User Name" with "Harry"
    And I fill in "Password" with "456"
    And I press "Log in"
    And I should be on the home page

  Scenario: My session should timeout after 20 minutes
    Given I am logged in
    And I expire my session
    And I am on the home page
    Then I should be on the login page
