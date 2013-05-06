Feature:

  So that all child records contains an audio for that child
  As a field agent using the website
  I want to upload an audio for the child record that I'm adding

  Background:
    Given "bob" logs in with "Register Child,Edit Child" permissions

  @gc
  Scenario: Uploading a standard mp3 file to new child record
    Given I am on the new child page 
    And I fill in "John" for "Name"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child record successfully created"
    And I click the "Photos and Audio" link
    And I should see an audio element that can play the audio file named "sample.mp3"
    And the record history should log "Record created by bob"

  @gc
  Scenario: Uploading a standard mp3 file to existing child record
    Given I am on the new child page
    And I fill in "Harry" for "Name"
    And I press "Save"
    Then I should see "Child record successfully created"

    When I am editing the child with name "Harry"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child was successfully updated"
    And I click the "Photos and Audio" link
    And I should see an audio element that can play the audio file named "sample.mp3"
    And the record history should log "Audio"
    And the record history should log "added by bob"

    When I am editing the child with name "Harry"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/sample.mp3"
    And I press "Save"
    Then I should see "Child was successfully updated"
    And I click the "Photos and Audio" link
    And I should see an audio element that can play the audio file named "sample.mp3"
    And the record history should log "Audio changed from"
    And the record history should log "by bob"

  @gc
  Scenario: Uploading an invalid file in the audio field
    Given I am on the new child page
    And I fill in "John" for "Name"
    And I click the "Photos and Audio" link
    And I attach an audio file "capybara_features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid audio file (amr or mp3) for this child record"








