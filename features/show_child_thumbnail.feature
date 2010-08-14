Feature:
  So that we can have a preview of the most recent uploaded photo of a child, a user should be able to see the thumbnail
  of the child's photo while editing the child's record

  Scenario: Seeing thumbnail when editing a child record
    Given I am logged in
    And an existing child with name "John" and a photo from "features/resources/jorge.jpg"
    When I am editing the child with name "John"
    Then I should see the thumbnail of "John"

