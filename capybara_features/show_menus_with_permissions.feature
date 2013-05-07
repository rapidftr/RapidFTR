Feature: show menus based on user permissions

  As A User without proper permissions
  So that when I log in I should not be able to see the Children,Devices,Users option.

  Scenario: Users and Devices option should not be visible without proper permissions

    Given an user "Jerry" with password "123"
    And I am on the login page
    When I fill in "Jerry" for "User Name"
    And I fill in "123" for "password"
    And I press "Log in"
    Then I should not be able to view the tab USERS
    And I should not be able to view the tab DEVICES

  Scenario: Children option should not be visible without proper permissions

    Given an senior official "Harry" with password "123"
    And I am on the login page
    When I fill in "Harry" for "User Name"
    And I fill in "123" for "password"
    And I press "Log in"
    Then I should not be able to view the tab CHILDREN
