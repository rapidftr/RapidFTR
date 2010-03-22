Feature:
  So that only those who should have access are able to access the system,
  an Admin should be able to disable and later re-enable user accounts via the web interface.

  # Scenario: Disabled user can't log in
  #   see user_login.feature

  Scenario: Admin disables a user from the edit page
    Given no users exist
    Given a user "george" with a password "p@ssw0rd"
    And I am logged in as an admin
    And I am on edit user page for "george"
    When I check "Disabled?"
    # XXX: re-enter password should go away once user admin is proper
    And I fill in "p@ssw0rd" for "Re-enter password"
    And I press "Update"
    Then user "george" should be disabled
