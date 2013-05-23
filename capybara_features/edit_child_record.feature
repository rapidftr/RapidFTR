Feature:

  As a user
  I want to go to a website and change the child's record
  So that I can update details of children that are found in the field

  Scenario: Editing a child record
    Given I am logged in as a user with "Register Child,Edit Child" permission

    # creating a record
    Given I am on children listing page
    And I follow "Register New Child"

    When I fill in "Name" with "Jorge Just"
    And I fill in "Date of Birth / Age" with "27"
    And I select "Male" from "Sex"
    And I fill in "Nationality" with "London"
    And I fill in "Birthplace" with "Haiti"
    And I follow "Photos and Audio"
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"

    # editing the created record
    Then I follow "Edit"
    When I fill in "Name" with "George Harrison"
    And I fill in "Date of Birth / Age" with "56"
    And I select "Female" from "Sex"
    And I fill in "Nationality" with "Bombay"
    And I fill in "Birthplace" with "Zambia"
    And I follow "Photos and Audio"
    And I attach a photo "capybara_features/resources/jeff.png"
    And I press "Save"

    # verifying whether the edited record has been saved successfully
    Then I should see "George Harrison"
    And I should see "56"
    And I should see "Female"
    And I should see "Bombay"
    And I should see "Zambia"
    And I follow "Photos and Audio"
    And I should see the photo of "George Harrison"
    And I should see "Child was successfully updated."

   # checking if validations are still working fine
    Then I follow "Edit"
    And I follow "Photos and Audio"
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  # cancel button should prompt user
    And the "Discard" button presents a confirmation message    

  Scenario: Should not be able to successfully edit child record with all empty fields
    Given I am logged in as a user with "Register Child,Edit Child" permission

    # creating a record
    Given I am on children listing page
    And I follow "New Child"

    When I fill in "Name" with "Jorge Just"
    And I press "Save"

    # editing the created record
    Then I follow "Edit"
    When I fill in "Name" with ""
    And I press "Save"

    Then I should see "Please fill in at least one field or upload a file"


