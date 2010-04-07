Feature: As a user
I want to view the relations recorded for a child
So I can know who they are, and whether the child should be reunited with them

Background:
Given I am logged in
And someone has entered a child with the name "Jessie"

Scenario: Viewing a child with some relations
  Given "Jessie" has the following relations:
  | type   | name  | reunite |
  | Uncle  | Dave  | Yes     |
  | Aunt   | Milly | No      |
  | Cousin | Hank  | No      |
	When I go to the saved record page for child with name "Jessie"
  Then I should see "Relatives"								
	And I should see "Uncle: Dave (reunite)"  
	And I should see "Aunt: Milly (do not reunite)"  
	And I should see "Cousin: Hank (do not reunite)"  

Scenario: Viewing a child with no relations
	When I go to the saved record page for child with name "Jessie"
  Then I should not see "Relatives"								
