Feature:
  Attempting to sync a record as an unverified user

  Scenario: An unverified user should be created on the server

	When I request the creation of the following unverified user:
      | user_name  | full_name   | organisation      | password    |
      | bbob       | Billy Bob   | save the children | 12345       |

    Then an unverified user "bbob" should be created
