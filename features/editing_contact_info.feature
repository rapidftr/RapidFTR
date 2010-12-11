Feature: Allowing admin contact info to be specified

  @wip
  Scenario: Viewing and editing the currently saved contact information
    Given the following admin contact info: 
      | key | value |
      | name | Fred Flintstone |
      | organization | UNICEF |
      | phone | 0123456 ext 2|
      | email | Foo@bar.com |
	And I am logged in as an admin
    When I am on the admin page
    And I follow "Admin Contact Information"
    Then the "Name" field should contain "Fred Flintstone"
    And the "Organization" field should contain "UNICEF"        
    And the "Phone" field should contain "0123456 ext 2"
    And the "Email" field should contain "Foo@bar.com"
	When I fill in "Barney Rubble" for "Name"
	And I fill in "Slate Rock and Gravel Company" for "Organization"
	And I press "Save"
	Then I should see "Contact information saved successfully"
	And the "Name" field should contain "Barney Rubble"
	Amd the "Organization" field should contain "Slate Rock and Gravel Company"
  Scenario: Only admins can edit contact info
 	When I am logged in
	Then I should not be able to see the edit administrator contact information page

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
