Feature:

  So that all child records contains a photo of that child
  As a field agent using the website
  I want to upload a picture of the child record that I'm adding

  Background:
    Given I am logged in as a user with "Register Child,Edit Child,View And Search Child" permission

  Scenario: Uploading a standard JPG image

    Given I am on the new child page
    When I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"

    Then I should see "Child record successfully created"
    And I should see the photo of "John"

  Scenario: Uploading multiple images along with audio file

    Given I am on the new child page
    
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach the following photos:
    |capybara_features/resources/jorge.jpg|
    |capybara_features/resources/jeff.png |
    |capybara_features/resources/jorge.jpg|
    |capybara_features/resources/jeff.png |
    |capybara_features/resources/jorge.jpg|
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of "John"
    And I click the "Photos and Audio" link
    Then I should see "5" thumbnails
    And I should see an audio element that can play the audio file named "sample.mp3"

    When I follow "Edit"
    And I click the "Photos and Audio" link
    Then I should see "5" thumbnails
    And I should see an audio element that can play the audio file named "sample.mp3"

  Scenario: Uploading an invalid file in the image field

    Given I am on the new child page
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I press "Save"

    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  Scenario: Changing the photo field on an existing child record

    Given I am editing an existing child record
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I press "Save"

    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  Scenario: Deleting an image

    Given I am on the new child page

    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach the following photos:
    |capybara_features/resources/jorge.jpg|
    |capybara_features/resources/jeff.png |

    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of "John"
    And I click the "Photos and Audio" link
    Then I should see "2" thumbnails

    When I follow "Edit"
    And I click the "Photos and Audio" link
    Then I should see "2" thumbnails
    And I check "Delete photo?"

    And I press "Save"
    Then I should see "Child was successfully updated"
    And I should see the photo of "John"
    And I click the "Photos and Audio" link
    Then I should see "1" thumbnails

  Scenario: Manage & Edit Photo

    Given I am on the new child page
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"
    When I goto the "edit_photo"
    Then I should be redirected to "Edit photo" Page
    And I should see "Rotate Anti-Clockwise"
    And I should see "Restore Original Image"
    And I should see "Rotate Clockwise"
    And I press "Save"
    When I goto the "manage_photo"
    Then I should be redirected to "Manage photos" Page
    And I should see "Choose as primary photo"
    And I should see "View full size photo"


  Scenario: Lightbox image is visible

    Given I am on the new child page
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"
    When I click the "Photos and Audio" link
    And I select the "image"
    Then I should see the "lightbox-nav" of image
