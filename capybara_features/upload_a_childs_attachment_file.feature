Feature:
  So that all child records contains an attachment for that child, including photo and audio
  As a field agent using the website
  I want to upload an attachment for the child record that I'm adding

  Background:
    Given "bob" logs in with "Register Child,Edit Child,View And Search Child" permissions

  Scenario: Uploading a standard mp3 file and a standard JPG image to new child record
    Given I am on the new child page
    When I fill in "Name" with "John"
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"
    Then I should see "Child record successfully created"

    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    And I should see the photo of "John"
    And the record history should log "Record created by bob"

  Scenario: Uploading an invalid file in the image and audio field
    Given I am on the new child page
    When I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I attach an audio file "capybara_features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"
    And I should see "Please upload a valid audio file (amr or mp3) for this child record"

  Scenario: Uploading multiple images
    Given I am on the new child page
    When I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach the following photos:
      |capybara_features/resources/jorge.jpg|
      |capybara_features/resources/jeff.png |
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of "John"

    When I click the "Photos and Audio" link
    Then I should see "2" thumbnails
    When I follow "Edit"
    And I click the "Photos and Audio" link
    Then I should see "2" thumbnails

  Scenario: Changing the photo field on an existing child record
    Given I am editing an existing child record
    When I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

  Scenario: Uploading a standard mp3 file to existing child record
    Given I am on the new child page
    When I fill in "Name" with "Harry"
    And I press "Save"
    Then I should see "Child record successfully created"

    When I am editing the child with name "Harry"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child was successfully updated"

    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    And the record history should log "Audio"
    And the record history should log "added by bob"

    When I am editing the child with name "Harry"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child was successfully updated"

    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    # WIP: And the record history should log "Audio changed"
    # WIP: And the record history should log "by bob"

  Scenario: Uploaded child audio file can be downloaded
    Given I am on the new child page
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"

    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    And I can download the "audio_link"

  Scenario: Photos and Audio field should always be visible
    Given I logout as "bob"
    And I am logged in as an admin
    When I am on the form section page
    Then the form section "Photos and Audio" should be listed as visible

    When I select the form section "photos_and_audio" to toggle visibility
    And I am on children listing page
    And I follow "Register New Child"
    Then I should see "Photos and Audio"

  Scenario: Should not be able to delete audio
    Given I am on the new child page
    And I fill in "Name" with "Harry"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"

    When I am editing the child with name "Harry"
    And I click the "Photos and Audio" link
    Then I should not see "Delete"

  Scenario: Should be able to delete photo
    Given I am on the new child page
    And I fill in "Name" with "John"
    And I click the "Photos and Audio" link
    And I attach the following photos:
      |capybara_features/resources/jorge.jpg|
      |capybara_features/resources/jeff.png |
    And I press "Save"
    Then I should see "Child record successfully created"
    And I should see the photo of "John"

    When I click the "Photos and Audio" link
    Then I should see "2" thumbnails

    When I follow "Edit"
    And I click the "Photos and Audio" link
    Then I should see "2" thumbnails

    When I check "Delete photo?"
    And I press "Save"
    Then I should see "Child was successfully updated"
    And I should see the photo of "John"

    When I click the "Photos and Audio" link
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
