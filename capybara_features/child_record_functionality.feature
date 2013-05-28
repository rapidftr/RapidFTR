Feature:
  Features related to child record, including view child record, view photo, view audio, create child record and filter child record etc.

  Background:
    Given I am logged in as a user with "Register Child,Edit Child,View And Search Child" permission
    And the following children exist in the system:
      | name     | last_known_location | reporter | unique_id    | reunited | flag  | duplicate | created_at             |flagged_at                   | reunited_at                  |
      | andreas  | London              | zubair   | zubairlon123 | true     | false | true      | 2004-02-03 04:05:06UTC | DateTime.new(2001,2,3,4,5,6)| DateTime.new(2001,2,3,4,5,6) |
      | zak      | London              | zubair   | zubairlon456 | false    | true  | false     | 2003-02-03 04:05:06UTC | DateTime.new(2004,2,3,4,5,6)| DateTime.new(2004,2,3,4,5,6) |
      | jaco     | NYC                 | james    | james456     | true     | true  | false     | 2002-02-03 04:05:06UTC |DateTime.new(2002,2,3,4,5,6) | DateTime.new(2002,2,3,4,5,6) |
      | meredith | Austin              | james    | james123     | false    | false | false     | 2001-02-03 04:05:06UTC |DateTime.new(2003,2,3,4,5,6) | DateTime.new(2002,2,3,4,5,6) |
      | jane     | Eyre                | james    | james153     | false    | false | true      | 2001-02-02 04:05:06UTC | DateTime.new(2008,2,3,4,5,6)| DateTime.new(2008,2,3,4,5,6) |
    And I am on the children listing page

  Scenario: Checking filter by All returns all the children in the system
    When I select "All" from "filter"
    Then I should see "andreas"
    And I should see "zak"
    And I should see "jaco"
    And I should see "meredith"
    And I should see "jane"

  @javascript
  Scenario: Checking filter by Active returns all the children who are not reunited in the system and who are not marked as duplicate of another child record
    When I select "Active" from "filter"
    Then I should see "zak"
    And I should see "meredith"
    And I should not see "andreas"
    And I should not see "jaco"
    And I should not see "jane"
    Then show me the page

  Scenario: Checking filter by All should by default show all children in alphabetical order
    Then I should see the order andreas,jaco,jane,meredith,zak

  Scenario: Checking filter by All shows the Order by options
    Then I should see "Order by"
    And I should see "Most recently created"

  @javascript
  Scenario: Checking filter by All and then ordering by most recently added returns all the children in order of most recently added
    When I select "Most recently created" from "order_by"
    Then I should see the order andreas,zak,jaco,meredith,jane

  Scenario: Checking filter by All sand then ordering by Name should return all the children in alphabetical order
    When I select dropdown option "Most recently created"
    And I select dropdown option "Name"
    Then I should see the order andreas,jaco,jane,meredith,zak

  @javascript
  Scenario: Checking filter by Reunited returns all the reunited children in the system
    When I select "Reunited" from "filter"
    Then I should see "andreas"
    And I should see "jaco"

  @javascript
  Scenario: Checking filter by Reunited shows the Order by options
    When I select "Reunited" from "filter"
    Then I should see "Order by"
    And I should see "Most recently reunited"

  @javascript
  Scenario: Checking filter by Reunited should by default show the records ordered alphabetically
    When I select "Reunited" from "filter"
    Then I should see the order andreas,jaco


  @javascript
  Scenario: Checking filter by Reunited and then selecting order by most recently reunited children returns the children in the order of most recently reunited
    When I select "Reunited" from "filter"
    And I select "Most recently reunited" from "order_by"
    Then I should see the order jaco,andreas

  @javascript
  Scenario: Checking filter by Reunited by name should show records in alphabetical order
    And I select "Reunited" from "filter"
    And I select "Most recently reunited" from "order_by"
    And I select "Name" from "order_by"
    Then I should see the order andreas,jaco

  @javascript
  Scenario: Checking filter by Flagged returns all the flagged children in the system
    When I select "Flagged" from "filter"
    Then I should see "zak"
    And I should see "jaco"

  @javascript
  Scenario: Checking filter by Flagged shows the Order by options
    When I select "Flagged" from "filter"
    Then I should see "Order by"
    And I should see "Most recently flagged"

  @javascript
  Scenario: Checking filter by Flagged returns all the flagged children in the system by order of most recently flagged
    When I select "Flagged" from "filter"
    And I select "Most recently flagged" from "order_by"
    Then show me the page
    Then I should see the order zak,jaco

  @javascript
  Scenario: Checking filter by Flagged and then ordering by name returns the flagged children in alphabetical order
    Given I select "Flagged" from "filter"
    And I select "Name" from "order_by"
    Then I should see the order jaco,zak

  @javascript
  Scenario: Checking filter by Flagged and ordering by most recently flagged returns the children in most recently flagged order
    When I select "Flagged" from "filter"
    And I select "Name" from "order_by"
    And I select "Most recently flagged" from "order_by"
    Then I should see the order zak,jaco

  Scenario: Checking filter by Active should by default show the records ordered alphabetically
    Then I should see the order jane,meredith,zak

  Scenario: Checking filter by Active shows the Order by options
    Then I should see "Order by"
    And I should see "Most recently created"

  @javascript
  Scenario: Checking filter by Active and then ordering by most recently created returns the children in the order of most recently created
    When I select "Most recently created" from "order_by"
    Then I should see the order zak,jaco,meredith,jane

  Scenario: Checking filter by Active and order by name should return the children in alphabetical order
    When I select "Most recently created" from "order_by"
    And I select "Name" from "order_by"
    Then I should see the order jaco,jane,meredith,zak

  Scenario: Viewing a child record with audio attached - mp3
    Given a child record named "Fred" exists with a audio file with the name "sample.mp3"
    When I am on the child record page for "Fred"
    Then I should see an audio element that can play the audio file named "sample.mp3"
    When I follow "Edit"
    Then I should see an audio element that can play the audio file named "sample.mp3"

  Scenario: Viewing a child record with audio attached - amr
    Given a child record named "Barney" exists with a audio file with the name "sample.amr"
    When I am on the child record page for "Barney"
    Then I should not see an audio tag

  Scenario: Date-times should be displayed according to the current user's timezone setting.
    Given the date/time is "July 19 2010 13:05:32UTC"
    And the following children exist in the system:
      | name       | age | age_is | gender | last_known_location |
      | Jorge Just | 27  | Exact  | Male   | Haiti               |
    And the date/time is "March 01 2010 17:59:33UTC"
    And the user's time zone is "(GMT-11:00) Samoa"

    When I am on the child record page for "Jorge Just"
    And I follow "Edit"
    And I fill in "Date of Birth / Age" with "28"
    And I press "Save"

    Then I should see /Registered by: .+ and others on 19 July 2010 at 02:05 \(SST\)/
    And I should see "Last updated: 01 March 2010 at 06:59 (SST)"

  Scenario: Editing a child record
    When I follow "Register New Child"
    And I fill in "Name" with "Jorge Just"
    And I fill in "Date of Birth / Age" with "27"
    And I select "Male" from "Sex"
    And I fill in "Nationality" with "London"
    And I fill in "Birthplace" with "Haiti"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jorge.jpg"
    And I press "Save"

    Then I follow "Edit"
    When I fill in "Name" with "George Harrison"
    And I fill in "Date of Birth / Age" with "56"
    And I select "Female" from "Sex"
    And I fill in "Nationality" with "Bombay"
    And I fill in "Birthplace" with "Zambia"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/jeff.png"
    And I press "Save"

    Then I should see "George Harrison"
    And I should see "56"
    And I should see "Female"
    And I should see "Bombay"
    And I should see "Zambia"
    And I click the "Photos and Audio" link
    And I should see the photo of "George Harrison"
    And I should see "Child was successfully updated."

    Then I follow "Edit"
    And I click the "Photos and Audio" link
    And I attach a photo "capybara_features/resources/textfile.txt"
    And I press "Save"
    Then I should see "Please upload a valid photo file (jpg or png) for this child record"

    And the "Discard" button presents a confirmation message

  Scenario: Should not be able to successfully edit child record with all empty fields
    When I follow "New Child"
    And I fill in "Name" with "Jorge Just"
    And I press "Save"
    Then I follow "Edit"
    When I fill in "Name" with ""
    And I press "Save"
    Then I should see "Please fill in at least one field or upload a file"

  Scenario:  Check that child record contains logged in user full name in created_by_full_name
    Given I am logged out
    And "jr_test" logs in with "Register Child" permissions
    And someone has entered a child with the name "kiloutou"
    Then I should see "Child record successfully created."
    And the field "created_by" of child record with name "kiloutou" should be "jr_test"
    And the field "created_by_full_name" of child record with name "kiloutou" should be "jr_test"

  Scenario: create child with approximate age
    Given I am on new child page
    When I fill in the basic details of a child
    And I press "Save"
    Then I should see "Child record successfully created."

  Scenario: create child with numeric custom field
    Given the following form sections exist in the system:
      | name          | unique_id     | editable  | order | visible |
      | Basic details | basic_details | false     | 1     | true    |
    And the "basic_details" form section has the field "Height" with field type "numeric_field"
    And I am on new child page
    When I fill in "Height" with "very tall"
    And I press "Save"
    Then I should see "Height must be a valid number"

  Scenario: cancel button should prompt user
    Given I am on new child page
    Then the "Discard" button presents a confirmation message

  Scenario: List on children link should link to Children List page
    Given I am on new child page
    When I follow "Children"
    Then I should be on children listing page


  Scenario: Child record must not display the edit and manage photos links
    Given the following children exist in the system:
      | name    | gender  | photo                                    |
      | John    | Male    | "capybara_features/resources/jorge.jpg"  |

    And I am on the child record page for "John"
    Then I should not see "Edit Photo"
    And I should not see "Manage Photo"

  Scenario: Seeing thumbnail when editing a child record
    Given an existing child with name "John" and a photo from "capybara_features/resources/jorge.jpg"
    When I am editing the child with name "John"
    Then I should see the thumbnail of "John"
