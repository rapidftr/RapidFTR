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

      Given I am logged in

      Then I should not see "Admin"

