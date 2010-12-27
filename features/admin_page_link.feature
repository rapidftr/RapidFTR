Feature: So that an admin user can access admin screens
  As a admin of the website
  I want to click on 'Admin' link and see the Administration home page

  Background:

    Scenario: From listing children page clicking on 'Admin' link redirects to admin start page

      Given I am logged in as an admin

      And I am on the child search page

      When I follow "Admin"

      Then I should be on the admin page


    Scenario: Non-Admin user should not see the Admin Link

      Given a user "Harry" with a password "123"

      And I am on the login page

      When I fill in "Harry" for "user name"

      And I fill in "123" for "password"

      And I press "Log in"

      Then I should not see "Admin"

