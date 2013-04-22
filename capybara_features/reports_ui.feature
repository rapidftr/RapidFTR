Feature: Reports UI

  Scenario: Browse and download a report
  Given the following reports exist in the system:
      | report_type   | as_of_date | file_name        | content_type | data        |
      | weekly_report | 2013-02-17 | test_report1.csv | text/csv     | TEST DATA 1 |
      | weekly_report | 2013-02-18 | test_report2.csv | text/csv     | TEST DATA 2 |
      | weekly_report | 2013-02-19 | test_report3.csv | text/csv     | TEST DATA 3 |
      | weekly_report | 2013-02-20 | test_report4.csv | text/csv     | TEST DATA 4 |
    And I am logged in as a user with "View and Download Reports" permission

    When I follow "REPORTS"
    Then I am on the reports page
    Then I should see "RapidFTR Reports"

    Then I should see the following reports:
      | as_of_date       |
      | February 20, 2013 |
      | February 19, 2013 |
      | February 18, 2013 |
      | February 17, 2013 |

    Then I follow "Download"
    Then a "text/csv" file named "test_report4.csv" should be downloaded
    And the downloaded file should have content:
      """
      TEST DATA 4
      """

  Scenario: Pagination of reports
    Given 40 reports exist in the system starting from February 20 2013
    And I am logged in as a user with "View and Download Reports" permission

    And I am on the reports page

    Then I should see "Displaying reports 1 - 30 of 40 in total"

    Then I follow "Next"
    Then I should see "Displaying reports 31 - 40 of 40 in total"

    Then I follow "Previous"
    Then I should see "Displaying reports 1 - 30 of 40 in total"

    Then I follow "2"
    Then I should see "Displaying reports 31 - 40 of 40 in total"

    Then I follow "1"
    Then I should see "Displaying reports 1 - 30 of 40 in total"
