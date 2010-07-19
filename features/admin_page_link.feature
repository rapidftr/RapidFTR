Feature: So that an admin user can access admin screens
  As a admin of the website
  I want to click on 'Admin' link and see the Administration home page

Background:
  Given I am logged in
  And I am on the child search page

  Scenario: From listing children page clicking on 'Admin' link redirects to admin start page
  When I follow "Admin"
  Then I should be on the admin page 

