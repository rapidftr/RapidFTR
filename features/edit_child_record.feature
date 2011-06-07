Feature:

  As a user
  I want to go to a website and change the child's record
  So that I can update details of children that are found in the field

  Scenario: Editing a child record
    Given I am logged in

    # creating a record
    Given I am on children listing page
    And I follow "New child"

    When I fill in "Jorge Just" for "Name"
    And I fill in "27" for "Date of Birth / Age"
    And I select "Male" from "Sex"
    And I fill in "London" for "Nationality"
    And I fill in "Haiti" for "Birthplace"
    And I attach a photo "features/resources/jorge.jpg"
    And I press "Save"

    # editing the created record
    Then I follow "Edit"
    When I fill in "George Harrison" for "Name"
    And I fill in "56" for "Date of Birth / Age"
    And I select "Female" from "Sex"
    And I fill in "Bombay" for "Nationality"
    And I fill in "Zambia" for "Birthplace"
    And I attach a photo "features/resources/jeff.png"
    And I press "Save"

    # verifying whether the edited record has been saved successfully
    Then I should see "George Harrison"
    And I should see "56"
    And I should see "Female"
    And I should see "Bombay"
    And I should see "Zambia"
    And I should see the photo of "George Harrison"
    And I should see "Child was successfully updated."

   # checking if validations are still working fine
    Then I follow "Edit"
    And I attach a photo "features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  # cancel button should prompt user
    And the "Discard" button presents a confirmation message    
