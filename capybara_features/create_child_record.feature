Feature: As a user I should be able to create new Child records


#  Story #622: Advanced Search - Search by User & Record Details
  Scenario:  Check that child record contains logged in user full name in created_by_full_name

    Given "jr_test" is logged in
    And someone has entered a child with the name "kiloutou"
    Then I should see "Child record successfully created."
    And the field "created_by" of child record with name "kiloutou" should be "jr_test"
    And the field "created_by_full_name" of child record with name "kiloutou" should be "jr_test"