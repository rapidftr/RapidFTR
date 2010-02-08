Feature:
  So that we can keep track of children that are found in the field, a user should be able to go to a website and upload
  basic information about the lost child.

  Scenario: To create a basic child record and verify whether it has been successfully created
    Given the database is empty
    Given I am on children listing page
    And I follow "New child"
    When I fill in "Jorge Just" for "Name"
    And I fill in "27" for "Age"
    And I check "Is age exact?"
    And I choose "Male"
    And I fill in "London" for "Origin"
    And I fill in "Haiti" for "Last known location"
    And I select "1-2 weeks ago" from "Date of separation"
    And I press "Create"

    Then I should see "Child record successfully created."
    And I should see "Jorge Just"
    And I should see "27"
    And I should see "Exact"
    And I should see "Male"
    And I should see "London"
    And I should see "Haiti"
    And I should see "1-2 weeks ago"

    When I follow "Back"
    Then I should see "Listing children"
    And I should see "Jorge Just"

    When I follow "Show"
    Then I follow "Back"
    And I should see "Listing children"
    And I should see "Jorge Just"
