Feature: MySQL connection

  Background:
    Given mysql container param "MYSQL_USER" is set to "user"
      And mysql container param "MYSQL_PASSWORD" is set to "pass"
      And mysql container param "MYSQL_DATABASE" is set to "db"

  Scenario: User account - smoke test
    When mysql container is started
    Then mysql connection can be established

  Scenario: Root account - smoke test
    Given mysql container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mysql container is started
     Then mysql connection with parameters can be established:
          | param          | value      |
          | MYSQL_USER     | root       |
          | MYSQL_PASSWORD | root_passw |
          | MYSQL_DATABASE | db         |

  Scenario Outline: Incorrect connection data - user account
    When mysql container is started
    Then mysql connection with parameters can not be established:
          | param          | value      |
          | MYSQL_USER     | <user>     |
          | MYSQL_PASSWORD | <password> |
          | MYSQL_DATABASE | <db>       |

    Examples:
    | user      | password | db  |
    | userr     | pass     | db  |
    | user      | passs    | db  |
    | user      | pass     | db1 |
    | \$invalid | pass     | db  |
    | user      | '        | db  |
    | user      | pass     | $invalid  |
    | user      | pass     | very_long_database_name_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  |
    | very_long_username | pass     | db  |

  Scenario Outline: Incorrect connection data - root account
    Given mysql container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mysql container is started
    Then mysql connection with parameters can not be established:
          | param          | value      |
          | MYSQL_USER     | root       |
          | MYSQL_PASSWORD | <password> |
          | MYSQL_DATABASE | <db>       |

    Examples:
    | password    | db  |
    | root_passw1 | db  |
    | root_passw  | db1 |
    | '           | db  |

  Scenario: Incomplete params
    When mysql container is started
    Then mysql connection with parameters can not be established:
          | param          | value |
          | MYSQL_USER     | user  |
          | MYSQL_PASSWORD | pass  |
     And mysql connection with parameters can not be established:
          | param          | value |
          | MYSQL_USER     | user  |
          | MYSQL_DATABASE | pass  |
     And mysql connection with parameters can not be established:
          | param          | value |
          | MYSQL_PASSWORD | pass  |
          | MYSQL_DATABASE | pass  |