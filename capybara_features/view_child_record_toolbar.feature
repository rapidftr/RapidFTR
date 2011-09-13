Feature: View Child Record Toolbar

  As a User, when I view a child record
  I want to see a toolbar
  So that I can perform various operations on that record

  Background:
    Given I am logged in
    And someone has entered a child with the name "Fred"
    When I am on the child record page for "Fred"

  Scenario: Child Record page contains two toolbars
    Then I should see 2 divs of class "profile-tools"

  Scenario: Top and bottom toolbar sections contain the expected links
    Then I should see the following links in the toolbars:
    | link_text              | link_class_name |
    | Back                   | back            |
    | Edit                   | edit            |
    | View the change log    | view-log        |
    | Export this Record     | export_record   |
    | Flag as suspect record | flag            |
    | Mark child as Reunited | reunited        |
