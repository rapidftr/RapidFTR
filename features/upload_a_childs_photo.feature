Feature:
  So that all child records contains a photo of that child
  As a field agent using the website
  I want to upload a picture of the child record that I'm adding

  Scenario: Uploading a standard JPG image
    Given I am logged in
    Given I am on the new child page
    When I fill in the basic details of a child
    And I attach the file "features/resources/jorge.jpg" to "photo"
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of the child

  Scenario: Uploading an image of type other than JPG
    Given I am logged in
    Given I am on the new child page
    When I fill in the basic details of a child
    And I attach the file "features/resources/jeff.png" to "photo"
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of the child with a "png" extension

  Scenario: Uploading an invalid file in the image field
    Given I am logged in
    Given I am on the new child page
    When I fill in the basic details of a child
    And I attach the file "features/resources/textfile.txt" to "photo"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  Scenario: I do not upload a photo
    Given I am logged in
    And I am on the new child page
    When I fill in "Haiti" for "Last known location"
    And I press "Save"
    Then I should see "Child record successfully created"

  Scenario: Changing the photo field on an existing child record
    Given I am logged in
    Given I am editing an existing child record
    And I attach the file "features/resources/textfile.txt" to "photo"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"
