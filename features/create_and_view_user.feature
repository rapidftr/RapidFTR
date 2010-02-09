Feature: As an admin, I should be able to create and view users.

  @wip
  Scenario:      To check that an admin creates a user record and is able to view it

    Given I am on admin homepage
    When I follow "manage users"
    When I fill in "George Harrison" for "Full Name"
    And I fill in "george" for "username"
    And I fill in "password" for "password"
    And I choose "user"
    And I fill in "abcd@unicef.com" for "email address"
    And I fill in "UNICEF" for "organisation"
    And I fill in "Rescuer" for "position"
    And I fill in "Amazon" for "location"
    And I follow "Create"
    Then I should see "George Harrison"
    And I should see "george"
    And I should see "user"
    And I should see "abcd@unicef.com"
    And I should not see "Rescuer"

    Scenario:                  To check for validations on the user record page
      Given I am on admin homepage
      When I follow "manage users"
      And I follow "Create"
      Then I should see "Please enter full name of the user"
      And I should see "Please enter the user name"
      And I should see "Please enter the password"
      And I should see "Please enter the user type"


    Scenario:              To check whether a user name already exists.
      Given I am on admin homepage
      When I follow "manage users"
      When I fill in "George Bush" for "Full Name"
      And I fill in "george" for "username"
      And I fill in "password" for "password"
      And I choose "user"
      And I follow "Create"
      Then I should see "Username already exists"
      When I fill in "bush" for "username"
      And I follow "Create"
      Then I should see "George Bush"


    Scenario: To check the validity of an email address
      Given I am on admin homepage
      When I follow "manage users"
      And I fill in "abcdunicef.com" for "email address"
      When I follow "Create"
      Then I should see "Please enter a valid email address"
      When I fill in "abcd@unicefcom" for "email address"
      Then I should see "Please enter a valid email address"








