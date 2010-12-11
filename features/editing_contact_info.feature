Feature: Allowing admin contact info to be specified

  Scenario: Viewing and editing the currently saved contact information
    Given the following admin contact info: 
      | key | value |
      | name | John Smith |
      | organization | UNICEF |
      | phone | 0123456 ext 2|
      | email | Foo@bar.com |
      | location | Uganda |
      | other_information | Lorem Ipsum Dolor sit amet... |
	And I am logged in as an admin
    When I am on the admin page
    And I follow "Admin Contact Information"
    Then the "Name" field should contain "John Smith"
    And the "Organization" field should contain "UNICEF"        
    And the "Phone" field should contain "0123456 ext 2"
    And the "Email" field should contain "Foo@bar.com"
    And the "Location" field should contain "Uganda"
    And the "Other information" field should contain "Lorem Ipsum Dolor sit amet..."
	When I fill in "Barney Rubble" for "Name"
	And I fill in "Slate Rock and Gravel Company" for "Organization"
	And I press "Save"
	Then I should see "Contact information was successfully updated."
	And the "Name" field should contain "Barney Rubble"
	And the "Organization" field should contain "Slate Rock and Gravel Company"
  Scenario: Only admins can edit contact info
 	When I am logged in
	Then I should not be able to see the edit administrator contact information page
	
  Scenario: Viewing administrator contact information 
    Given the following admin contact info: 
      | key | value |
      | name | John Smith |
      | organization | UNICEF |
      | phone | 0123456 ext 2|
      | email | Foo@bar.com |
      | location | Uganda |
      | other_information | Please let us know if your password goes missing! |
	And I am logged in
	When I follow "Contact & Help"
	Then I should be on the administrator contact page
	And I should see "John Smith" within "#contact_info_name"
	And I should see "UNICEF" within "#contact_info_organization"
	And I should see "0123456 ext 2" within "#contact_info_phone"
	And I should see "Foo@bar.com" within "#contact_info_email"
	And I should see "Uganda" within "#contact_info_location"
	And I should see "Please let us know if your password goes missing!" within "#contact_info_other_information"
  
  # Background:
  #   Given I am logged in
  # 
  # Scenario: From saved record page clicking on 'Home' link redirects to initial start page
  #   Given the following children exist in the system:
  #     | name  |
  #     | Lisa	|
  #   And I am on the child search page
  # 
  #   When I search using a name of "Lisa"
  #   Then I should be on the saved record page for child with name "Lisa"
  # 
  #   When I follow "Home"
  #   Then I should be on the home page
  # 
  # Scenario: The homepage should contain useful links and welcome text
  # 
  #   Given I am on the home page
  # 
  #   Then I should see "Welcome to RapidFTR"
  #   Then I should see "Add child record"
  #   Then I should see "View child listing"
