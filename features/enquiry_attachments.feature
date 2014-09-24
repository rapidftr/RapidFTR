Feature: Uploading enquiry attachments

  Background:
    Given the following forms exist in the system:
      | name      |
      | Enquiries |
    And the following form sections exist in the system on the "Enquiries" form:
      | name             | unique_id           | editable | order | visible | perm_enabled |
      | Enquiry Criteria | enquiry_criteria    | false    | 1     | true    | false        |
      | Photos and Audio | enquiry_attachments | false    | 2     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name              | type        | display_name  | editable | matchable  |
      | enquirer_name_001 | text_field  | Enquirer Name | false    | true       |
      | child_name_001    | text_field  | Child's Name  | false    | true       |
    And the following fields exists on "enquiry_attachments":
      | name          | type             | display_name  | editable | matchable  |
      | photo_1_001   | photo_upload_box | Photo One     | false    | false      |
      | audio_001     | audio_upload_box | Audio         | false    | false      |
    And I am logged in as a user with "Create Enquiry,View Enquiries,Update Enquiry" permissions

  Scenario: Uploading a standard mp3 file and a standard JPG image to new enquiry record
    When I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "Jorge Just"
    And I attach an enquiry audio file "features/resources/sample.mp3" 
    And I attach an enquiry photo "features/resources/jorge.jpg"
    And I press "Save"
    Then I should see "Enquiry record successfully created"
    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    And I should see the enquiry thumbnail of "Charles"
    And the enquiry history should log "Record created by mary"

  Scenario: Uploading an invalid file in the image and audio field
    Given I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "Jorge Just"
    And I attach an enquiry photo "features/resources/textfile.txt"
    And I attach an enquiry audio file "features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"
    And I should see "Please upload a valid audio file (amr or mp3) for this child record"

  Scenario: Uploading multiple images
    Given I follow "Register New Enquiry"
    And I fill in "Enquirer Name" with "Charles"
    And I fill in "Child's Name" with "Jorge Just"
    And I attach the following photos to enquiry:
      |features/resources/jorge.jpg|
      |features/resources/jeff.png |
    And I press "Save"
    Then I should see "Enquiry record successfully created"
    And I should see the enquiry photo of "Charles"
    When I click the "Photos and Audio" link
    Then I should see "2" thumbnails
    When I follow "Edit"
    And I click the "Photos and Audio" link
    Then I should see "2" thumbnails

  Scenario: Uploading a standard mp3 file to existing enquiry record
    Given the following enquiries exist in the system:
      | unique_identifier | _id   | enquirer_name_001 | child_name_001 |
      | 0001              | 0001  | bob               | bob chulu      |
    And I follow "ENQUIRIES"
    And I follow "0001"
    And I follow "Edit"
    And I click the "Photos and Audio" link
    And I attach an enquiry audio file "features/resources/sample.mp3"
    And I press "Save"
    
    Then I should see "Enquiry record successfully updated"
    When I click the "Photos and Audio" link
    Then I should see an audio element that can play the audio file named "sample.mp3"
    And I follow "Change Log"
    And the enquiry history should log "Audio"
    And I debug
    And the enquiry history should log "added by mary"

  #   When I am editing the child with name "Harry"
  #   And I click the "Photos and Audio" link
  #   And I attach an audio file "features/resources/sample.mp3"
  #   And I press "Save"
  #   Then I should see "Child was successfully updated"

  #   When I click the "Photos and Audio" link
  #   Then I should see an audio element that can play the audio file named "sample.mp3"
  #   # WIP: And the record history should log "Audio changed"
  #   # WIP: And the record history should log "by bob"

  # Scenario: Uploaded child audio file can be downloaded
  #   Given I am on the new child page
  #   And I fill in "Name" with "John"
  #   And I click the "Photos and Audio" link
  #   And I attach an audio file "features/resources/sample.mp3"
  #   And I press "Save"

  #   When I click the "Photos and Audio" link
  #   Then I should see an audio element that can play the audio file named "sample.mp3"
  #   And I can download the "audio_link"

  # Scenario: Photos and Audio field should always be visible
  #   Given I logout as "bob"
  #   And I am logged in as an admin
  #   When I am on the form sections page for "Children"
  #   Then the form section "Photos and Audio" should be listed as visible

  #   When I select the form section "photos_and_audio" to toggle visibility
  #   And I am on children listing page
  #   And I follow "Register New Child"
  #   Then I should see "Photos and Audio"
