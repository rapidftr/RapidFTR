Feature: So that a user can get back to their initial start page from anywhere within the application
  As a user of the website
  I want to click on 'CHILDREN' link and return to initial start page

  @wip
  Scenario: From saved record page clicking on 'CHILDREN' link redirects to initial start page
    Given I am logged in
    And the following children exist in the system:
      | name  |
      | Lisa	|
    And I am on the child search page

    When I search using a name of "Lisa"
    Then I should be on the saved record page for child with name "Lisa"

    When I follow "Home"
    Then I should be on the home page

  @wip
  Scenario: The homepage should contain useful links and welcome text
    Given I am logged in
    And I am on the home page
    Then I should see "Welcome to RapidFTR"
    And I should see "Register New Child"
    And I should see "View All Children"
    And I should not see "Records need Attention"

  @wip
  Scenario: Admin users should see records need Attention
    Given I am logged in as an admin
    And I am on the home page
    And I should see "Records need Attention"

  Scenario: Clicking on 'RapidFTR logo' link redirects to home page
    Given I am logged in
    And I am on the home page
    When I follow "RapidFTR logo"
    Then I should be on the home page

  Scenario: Clicking on 'RapidFTR logo' link redirects to home page
    Given I am on the home page
    When I follow "RapidFTR logo"
    Then I should be on the login page

