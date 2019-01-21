# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project follows MariaDB versioning.

## [10.3.12] - 2019-01-21
### Changed
  - Upgrade MariaDB version to 10.3.12

## [10.3.10] - 2018-11-08
### Changed
  - Upgrade MariaDB version to 10.3.10

## [10.3.8] - 2018-07-29
### Changed
  - Upgrade MariaDB version to 10.3.8
  - Now use mariabackup instead of xtrabackup

## [10.2.14-1] - 2018-04-09
### Fixed
  - User and database init

## [10.2.14] - 2018-03-28
### Changed
  - Upgrade MariaDB version to 10.2.14

## [10.2.13] - 2018-02-14
### Changed
  - Upgrade MariaDB version to 10.2.13

## [10.2.12] - 2018-01-16
### Changed
  - Upgrade MariaDB version to 10.2.12

## [10.2.11] - 2017-11-29
### Changed
  - Upgrade MariaDB version to 10.2.11

## [10.2.10] - 2017-11-17
### Changed
  - Upgrade MariaDB version to 10.2.10

## [10.2.9] - 2017-11-09
### Changed
  - Upgrade MariaDB version to 10.2.9
  - Upgrade baseimage to light-baseimage:1.1.1

## [10.2.8] - 2017-10-06
### Changed
  - Upgrade MariaDB version to 10.2.8
  - Move config to assets/config folder
  - Use UTF8 by default

## [10.2.6] - 2017-07-19
### Added
  - MARIADB_DATABASES and MARIADB_USERS environment variable, to create databases and users.

### Changed
  - Upgrade MariaDB version to 10.2.6
  - Upgrade baseimage to light-baseimage:1.1.0 (debian stretch)

## [10.1.23] - 2017-05-09
### Changed
  - Upgrade MariaDB version to 10.1.23

## [10.1.22] - 2017-03-15
### Changed
  - Upgrade MariaDB version to 10.1.22

### Fixed
  - Restoration of not running database

## [10.1.21] - 2017-02-18
### Changed
  - Upgrade MariaDB version to 10.1.21

## [10.1.20] - 2016-12-16
### Changed
  - Upgrade MariaDB version to 10.1.20

## [10.1.19] - 2016-11-08
### Added
  - Backups are now compressed and chmod 600

### Changed
  - Upgrade xtrabackup version to 2.4
  - Upgrade MariaDB version to 10.1.19
  - Upgrade baseimage to light-baseimage:0.2.6

## [10.1.18] - 2016-10-15
### Changed
  - Upgrade MariaDB version to 10.1.18

## Versions before following the MariaDB versioning

## [0.2.11] - 2016-09-02
### Changed
  - Upgrade baseimage to light-baseimage:0.2.5
  - Upgrade MariaDB version to 10.1.17

## [0.2.10] - 2016-07-26
### Changed
  - Upgrade baseimage to light-baseimage:0.2.4
  - Upgrade MariaDB version to 10.1.16

## [0.2.9] - 2016-02-20
### Changed
  - Upgrade baseimage to light-baseimage:0.2.2
  - Upgrade MariaDB version to 10.1.11

## [0.2.8] - 2015-12-16
### Added
  - Makefile with build no cache

### Changed
  - Upgrade baseimage to light-baseimage:0.2.0
  - Upgrade MariaDB version to 10.1.9

## [0.2.7] - 2015-11-20
### Changed
  - Upgrade baseimage to light-baseimage:0.1.5

## [0.2.6] - 2015-11-19
### Changed
  - Upgrade baseimage to light-baseimage:0.1.4
  - More easy configuration

## [0.2.5] - 2015-10-23
### Added
  - Add ssl support
  - Add xtrabackup

### Changed
  - MariaDB version 10.1.8
  - Use light-baseimage:0.1.2

## [0.2.4] - 2015-03-03
### Changed
  - Allow single MARIADB_ROOT_ALLOWED_NETWORKS simply by -e MARIADB_ROOT_ALLOWED_NETWORKS=host instead of -e MARIADB_ROOT_ALLOWED_NETWORKS=['host']

## [0.2.3] - 2015-03-02
### Added
  - Custom my.cnf

## [0.2.2] - 2015-02-23
### Changed
  - Upgrade baseimage to baseimage:10.2

### Fixed
  - Install bugs

## [0.2.1] - 2015-01-23
### Added
  - Use Bats as testing tools

### Changed
  - Upgrade baseimage to baseimage:10.1
  - Simplify project tree

## [0.2.0] - 2014-10-15
### Added
  - Add changelog

### Changed
  - Upgrade baseimage to baseimage:0.9.0
  - Change docker command from docker.io to docker

[10.3.12]: https://github.com/osixia/docker-mariadb/compare/v10.3.10...v10.3.21
[10.3.10]: https://github.com/osixia/docker-mariadb/compare/v10.3.8...v10.3.10
[10.3.8]: https://github.com/osixia/docker-mariadb/compare/v10.2.14-1...v10.3.8
[10.2.14-1]: https://github.com/osixia/docker-mariadb/compare/v10.2.14...v10.2.14-1
[10.2.14]: https://github.com/osixia/docker-mariadb/compare/v10.2.13...v10.2.14
[10.2.13]: https://github.com/osixia/docker-mariadb/compare/v10.2.12...v10.2.13
[10.2.12]: https://github.com/osixia/docker-mariadb/compare/v10.2.11...v10.2.12
[10.2.11]: https://github.com/osixia/docker-mariadb/compare/v10.2.10...v10.2.11
[10.2.10]: https://github.com/osixia/docker-mariadb/compare/v10.2.9...v10.2.10
[10.2.9]: https://github.com/osixia/docker-mariadb/compare/v10.2.8...v10.2.9
[10.2.8]: https://github.com/osixia/docker-mariadb/compare/v10.2.6...v10.2.8
[10.2.6]: https://github.com/osixia/docker-mariadb/compare/v10.1.23...v10.2.6
[10.1.23]: https://github.com/osixia/docker-mariadb/compare/v10.1.22...v10.1.23
[10.1.22]: https://github.com/osixia/docker-mariadb/compare/v10.1.21...v10.1.22
[10.1.21]: https://github.com/osixia/docker-mariadb/compare/v10.1.20...v10.1.21
[10.1.20]: https://github.com/osixia/docker-mariadb/compare/v10.1.19...v10.1.20
[10.1.19]: https://github.com/osixia/docker-mariadb/compare/v10.1.18...v10.1.19
[10.1.18]: https://github.com/osixia/docker-mariadb/compare/v0.2.11...v10.1.18
[0.2.11]: https://github.com/osixia/docker-mariadb/compare/v0.2.10...v0.2.11
[0.2.10]: https://github.com/osixia/docker-mariadb/compare/v0.2.9...v0.2.10
[0.2.9]: https://github.com/osixia/docker-mariadb/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/osixia/docker-mariadb/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/osixia/docker-mariadb/compare/v0.2.6...v0.2.7
[0.2.6]: https://github.com/osixia/docker-mariadb/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/osixia/docker-mariadb/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/osixia/docker-mariadb/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/osixia/docker-mariadb/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/osixia/docker-mariadb/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/osixia/docker-mariadb/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/osixia/docker-mariadb/compare/v0.1.0...v0.2.0
