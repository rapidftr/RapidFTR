Feature: So that hard copy printout of missing enquiry photos are available
  As a user
  I want to be able to export selected enquiries to a PDF or a CSV file
  
  Background:
  Given the following forms exist in the system:
      | name      |
      | Enquiries |
      | Children  |
    And the following form sections exist in the system on the "Enquiries" form:
      | name             | unique_id        | editable | order | visible | perm_enabled |
      | Enquiry Criteria | enquiry_criteria | false    | 1     | true    | true         |
    And the following fields exists on "enquiry_criteria":
      | name             | type       | display_name  | editable | matchable  |
      | enquirer_name    | text_field | enquiry_name  | false    | true       |
      | unique_id        | text_field | unique_id     | false    | true       |
      | created_by       | text_field | created_by    | false    | true       |
      | action           | text_field | action        | false    | true       |
      | photo_path       | text_field | photo_path    | false    | true       |

    Given I am logged in as a user with "View Enquiry,Export to Photowall,Export to CSV,Export to PDF,Edit Enquiry" permissions
    And the following enquiries exist in the system:
      | enquiry_name | unique_id  | created_by |
      | Will         | will_uid   | user1      |
      | Willis       | willis_uid | user1      |
      | Wilma        | wilma_uid  | user1      |

  # @javascript
  # Scenario Outline: Exporting full PDF from the enquiries page
  #   Given I am on the enquiries listing page
  #   When I follow "Export" for enquiry records
  #   And I follow "<action>" for enquiry records
  #   Then password prompt should be enabled
  # Examples:
  #   |action                  |
  #   |Export All to Photo Wall|
  #   |Export All to PDF       |
  #   |Export All to CSV       |
  
  # @javascript
  # Scenario: Exporting PDF when there is no photo
  #   Given the following enquiries exist in the system:
  #     | enquiry_name           | unique_id            | photo_path |
  #     | Billy No Photo | billy_no_photo_uid   |            |
  #   When I am on the saved record page for enquiry with enquiry_name "Billy No Photo"
  #   And I follow "Export"
  #   And I follow "Export to PDF"
  #   Then password prompt should be enabled

  # Scenario: A user without file export permissions should not be able to export files
  #   Given I logout as "Mary"
  #   And an registration worker "john" with password "123"
  #   When I fill in "user_name" with "john"
  #   And I fill in "password" with "123"
  #   And I go and press "Login"
  #   And I fill in "query" with "Wil"
  #   And I press "Go"
  #   Then "export" option should be unavailable to me


  