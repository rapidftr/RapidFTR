Feature: As a device manager, I should be able to blacklist or un blacklist a device

  @javascript
  Scenario: Should able to blacklist a device

    Given I am logged in as a user with "BlackList Devices" permission
    When I have the following devices:
      | user_name | imei        | blacklisted |
      | bob       | 82828282882 | true        |
      | adam      | 1212121212  | false       |
      | eve       | 1212121212  | false       |
    When I am on devices listing page
    Then I click blacklist for "1212121212"
    And I wait for the page to load
    Then device "1212121212" should be blacklisted
    Then I click blacklist for "82828282882"
    And I wait for the page to load
    Then device "82828282882" should not be blacklisted
