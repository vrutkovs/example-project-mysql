Feature: MySQL connection

  Background:
    Given mysql container param "MYSQL_USER" is set to "user"
      And mysql container param "MYSQL_PASSWORD" is set to "pass"
      And mysql container param "MYSQL_DATABASE" is set to "db"

  Scenario: User account - smoke test
    When mysql container is started
    Then mysql connection can be established

  Scenario Outline: Incorrect connection data - user account
    When mysql container is started
    Then mysql connection via user "<user>", password "<password>" and db "<db>" can not be established

    Examples:
    | user  | password | db  |
    | userr | pass     | db  |
    | user  | passs    | db  |
    | user  | pass     | db1 |

  Scenario: Root account - smoke test
    Given mysql container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mysql container is started
     Then mysql connection via user "root", password "root_passw" and db "db" can be established

  Scenario Outline: Incorrect connection data - user account
    Given mysql container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mysql container is started
     Then mysql connection via user "root", password "<password>" and db "<db>" can not be established

    Examples:
    | password    | db  |
    | root_passw1 | db  |
    | root_passw  | db1 |