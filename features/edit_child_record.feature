Feature:
  So that we can update details of children that are found in the field, a user should be able to go to a website and change
  the child's record

  Scenario: Editing a child record
    Given no children exist
    # creating a record

    Given I am on children listing page
    And I follow "New child"
    When I fill in "Jorge Just" for "Name"
    And I fill in "27" for "Age"
    And I select "Exact" from "Age is"
    And I choose "Male"
    And I fill in "London" for "Origin"
    And I fill in "Haiti" for "Last known location"
    And I select "1-2 weeks ago" from "Date of separation"
    And I attach the file "features/resources/jorge.jpg" to "photo"
    And I press "Create"

   # editing the created record
   Then I follow "Edit"
   When I fill in "George Harrison" for "Name"
    And I fill in "56" for "Age"
    And I select "Approximate" from "Age is"
    And I choose "Female"
    And I fill in "Bombay" for "Origin"
    And I fill in "Zambia" for "Last known location"
    And I select "6 months to 1 year ago" from "Date of separation"
    And I attach the file "features/resources/jeff.png" to "photo"
    And I press "Update"

  # verifying whether the edited record has been saved successfully
    Then I should see "George Harrison"
    And I should see "56"
    And I should see "Approximate"
    And I should see "Female"
    And I should see "Bombay"
    And I should see "Zambia"
    And I should see "6 months to 1 year ago"
    And I should see the photo of the child with a "png" extension
    And I should see "Child was successfully updated."

 #checking if validations are still working fine 

    Then I follow "Edit"
   # And I attach the file "features/resources/textfile.txt" to "photo"
    And I fill in "" for "Last known location"
    And I press "Update"
 #   Then I should see "Please upload a valid photo file (jpg or png) for this child record"
    Then I should see "Last known location cannot be empty"
    


 
    


