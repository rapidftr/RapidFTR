@wip
Feature: So that a user can view sidebar links
  As a user of the website
  I want to see the sidebar links

  Background:

    Scenario: Users should be able to navigate 'Search' and 'Advanced Search' links on the 'View All Children' page

      Given I am logged in

      And I am on children listing page

      Then I should see a link to the child search page

      Then I should see a link to the advanced child search page

    Scenario: Users should be able to navigate 'View All Children' and 'Advanced Search' links on the 'Search' page

      Given I am logged in

      And I am on the child search page

      Then I should see a link to the children listing page

      Then I should see a link to the advanced child search page

    Scenario: Users should be able to navigate 'View All Children' and 'Search' links on the 'Advanced Search' page

      Given I am logged in

      And I am on the advanced child search page

      Then I should see a link to the children listing page

      Then I should see a link to the child search page
