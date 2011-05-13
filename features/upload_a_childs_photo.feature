Feature:

  So that all child records contains a photo of that child
  As a field agent using the website
  I want to upload a picture of the child record that I'm adding

  Background:
    Given I am logged in

  Scenario: Uploading a standard JPG image

    Given I am on the new child page

    When I fill in "Haiti" for "Last known location"
    And I fill in "John" for "Name"
    And I attach a photo "features/resources/jorge.jpg"
    And I press "Save"

    Then I should see "Child record successfully created"
    And I should see the photo of "John"

  Scenario: Uploading multiple images

    Given I am on the new child page

    When I fill in "Haiti" for "Last known location"
    And I fill in "John" for "Name"
    And I attach the following photos:
    |features/resources/jorge.jpg|
    |features/resources/jeff.png |
      
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of "John"
    Then I should see "2" thumbnails    
        
    When I follow "Edit"
    Then I should see "2" thumbnails

  Scenario: Uploading an invalid file in the image field

    Given I am on the new child page
    When I fill in "Haiti" for "Last known location"
    And I fill in "John" for "Name"
    And I attach a photo "features/resources/textfile.txt"
    And I press "Save"

    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  Scenario: Changing the photo field on an existing child record

    Given I am editing an existing child record
    And I attach a photo "features/resources/textfile.txt"
    And I press "Save"

    Then I should see "Please upload a valid photo file (jpg or png) for this child record"
