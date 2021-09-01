# Change log

## master (unreleased)

### Added

* To create plan with attribute :api_created
* Actualize rubocop configs and add it's extensions
* Add `rubocop` check to CI
* Add `markdownlint` check in CI
* Add `.bundle` folder to `gitignore`

### Changed

* Database scheme for simplification in future
* Actualize dependabot config
* Use `palladium` from gem, not from git sources
* Fix different typos in all parts of project

## 0.6.0

### Added

* Ability for multi-deleting
* Increase performance x4 in run statistic getting

### Fix

* Deleted suite now will not to be add to new plans
* Change case delete strategy

## 0.5.2

* Fixes: change max database connections to 10 by default

## 0.5.1

### Changed

* Get plan method not sent plans and plan statistic. Now it is different methods

### Added

* Method for getting plan statistic
* Tests for getting plans statistic

## 0.5.0

### Changed

* Change getting plans. Now you can get only 3  plan in one time,
  or get all plans younger plan_id

## 0.4.4 (2019-05-29)

### Changed

* Dockerfile and docker-compose file for testing and deploy
* Delete default secret keys
* Rewrite all tests. Add new framework for tests

### Add

* Add new database: user settings. Not implemented to interface

## 0.4.3 (2018-11-14)

### Changed

* History os not uniq object. Now it a generic result set
  with new fiend - plan(with plan values)

## 0.4.2 (2018-10-30)

### Fixed

* Phantom products after deleting

## 0.4.1 (2018-10-22)

### Fixed

* 403 error for all post requests to /api from firefox

## 0.4.0 (2018-07-11)

### Changed

* Delete most of hooks

## 0.3.1 (2018-06-27)

### Fixed

* Wrong request scope in result_sets_by_status
* Fix creating nil objects after set product position and delete this product

### Changes

* result_sets_by_status will return empty array of result sets and
  status_error is status not found

## 0.3.0 (2018-04-05)

### Added

* New method to api: getting result_sets by statuses and etc. data

## 0.2.1 (2018-03-28)

### Changed

* Min password size

### Fixed

* Error after change product positions
* Send error it registration email is already taken

## 0.2.0 (2018-03-28)

### Changed

* All '/' methods is in 'public' namespace now

## 0.1.1 (2018-03-20)

### Added

* Opportunity to save product position in list

## 0.1.0 (2018-02-15

### Added

* Add errors after creating product without name
* Test for product validation
* Change response of most part requests for errors checks

### Fixed

* Fix errors after multiple result adding by case name or case id
* Fix errors after name change

## 0.0.1 (2018-01-30)

### Fixed

* Fixed error after incorrect product name from edit product method

### Added

* Rubocop files for code style
* Changelog file
* Public method `version`. In return current version of application
* Add test for `version` method
