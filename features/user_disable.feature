Feature:

  As an Admin 
  I want to disable and later re-enable user accounts via the web interface
  So that only those who should have access are able to access the system,

  # Scenario: Disabled user can't log in
  #   see user_login.feature

  Scenario: Admin disables a user from the edit page

    Given a user "george"
    And an admin "adam"
    And I am logged in as "adam"
    And I am on edit user page for "george"

    When I check "Disabled?"
    # XXX: re-enter password should go away once user admin is proper
    And I fill in "123" for "Re-enter password"
    And I press "Update"
    Then user "george" should be disabled
    When I am on the manage users page
    And the user "george" should be marked as disabled

  Scenario: Admin re-enables a user from the edit page

    Given a user "george"
    And an admin "adam"
    And user "george" is disabled
    And I am logged in as "adam"
    And I am on edit user page for "george"

    When I uncheck "Disabled?"
    # XXX: re-enter password should go away once user admin is proper
    And I fill in "123" for "Re-enter password"
    And I press "Update"

    Then user "george" should not be disabled
    When I go to the manage users page
    And the user "george" should be marked as enabled
  @allow-rescue
  Scenario: A user who is disabled mid-session can't continue using that session

    Given a user "george"
    And I am logged in as "george"
    And I am on the children listing page

    When user "george" is disabled
    And I follow "New child"

    Then I should have received a "401 Unauthorized" status code
