Feature: So that a user can get back to their initial start page from anywhere within the application
  As a user of the website
  I want to click on 'Home' link and return to initial start page

Background:
  Given I am logged in
  And I am on the child search page

  Scenario: From saved record page clicking on 'Home' link redirects to initial start page
  Given the following children exist in the system:
    | name  |
    | Lisa	|
  When I search using a name of "Lisa"
  Then I should be on the saved record page for child with name "Lisa"
  When I follow "Home"
  Then I should be on the home page 

