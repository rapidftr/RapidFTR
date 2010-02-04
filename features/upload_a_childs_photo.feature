Feature:
  So that all child records contains a photo of that child
  As a field agent using the website
  I want to upload a picture of the child record that I'm adding

Scenario:
  Given I am on the new child page
  When I fill in the basic details of a child
  And I attach the file "features/resources/jorge.jpg" to "photo"
  And I press "Create"
  Then I should be on the view child   record page
  And I should see the photo of the child
  

  