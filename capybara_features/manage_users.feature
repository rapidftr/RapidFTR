Feature: Manage Users

#Story: Changing user disabled status from user list page

  Background:
    Given a user "jerry"
    Given I am logged in as an admin

    And I follow "USERS"

  @javascript
  Scenario: Admins should be able to change user disabled status from index page

    And user "jerry" is disabled
    And the user "jerry" is marked as disabled
    When I follow "Logout"
    And I am logged in as an admin
    And I follow "USERS"
    When I re-enable user "jerry"
    And the user "jerry" is marked as enabled
    Then user "jerry" should not be disabled
    And the user "jerry" should be marked as enabled

  Scenario: Admins should be able view himself
     Then I should see "Show"
    Then I should see "Edit"
     Then I should not see "Delete" within "#user-row-admin"
     Then I should see "Back"
     Then I should see "Create User"

  Scenario: On the show User page, the breadcrumb consists of List User link and User Name
    When I follow "Show" within "#user-row-jerry"
    Then I should see "jerry (Edit)"
    And I am on manage users page

  Scenario: On the edit User page, the breadcrumb consists of Edit User link and User Name
    When I follow "Edit" within "#user-row-jerry"
    Then I should see "Users > jerry"
    Then I follow "Users"
   And I am on manage users page

  Scenario: On the create User page, the breadcrumb consists of List Users page
    Then I follow "Create User"
    Then I follow "Users"
    And I am on manage users page

  Scenario: User clicks Cancel button and is then on the listing page
     When I follow "Edit" within "#user-row-jerry"
     Then I follow "Cancel"
     And I am on manage users page

   Scenario: User clicks Save button on Edit User page and is then on User listing page
     When I follow "Edit" within "#user-row-jerry"
     Then I fill in "9876543210" for "Phone"
     And I press "Update"
     Then I should see "9876543210"

  @javascript
   Scenario: User should be able to see active users sorted by Full Name by default on User Listing page
     Given a user "henry"
     And a user "homer"
     And user "homer" is disabled
     And I am on manage users page
     Then I should see the following users:
     |name |
     |admin|
     |henry|
     |jerry|
     And I should not see "homer"

  @javascript
  Scenario: User should be able to see active users sorted by User Name on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "User Name" from "sort"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |jerry|
    And I should not see "homer"

  @javascript
  Scenario: User should be able to see all users sorted by Full Name on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "All" from "filter"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |homer|
      |jerry|

  @javascript
  Scenario: User should be able to see all users sorted by User Name on User Listing page
    Given a user "henry"
    And a user "homer"
    And user "homer" is disabled
    And I am on manage users page
    And I select "All" from "filter"
    And I select "User Name" from "sort"
    Then I should see the following users:
      |name |
      |admin|
      |henry|
      |homer|
      |jerry|

  @javascript
  Scenario: Admin should be able to see the timestamp under device information
    Given a user "jerry" has logged in from a device
    And I am on manage users page
    And I follow "Show" within "#user-row-jerry"
    Then I should see "2012-12-17 09:53:51 UTC"
