# Change log

## master (unreleased)

### New Features

* Add `ruby-3.4` to CI

### Changes

* Remove any mentions of `travis-ci` from the project (It's not used any more)
* Use `docker compose` instead of `docker-compose`
* Cleanup `.rubocop_todo.yml` according to changes to `rubocop-sequel-0.3.5`
* Use `ruby-3.4` as base for Docker image
* Fix minor code issue found by `rubocop-1.70.0`
* Fix `rubocop-1.72.0` cop `Style/RedundantParentheses`

### Fixes

* Run `rubocop` in CI through `bundle exec`

### Tests

* Replace deprecated `faker` call for `Faker::TvShows::Buffy.celebrity`

## 0.7.0 (2024-06-21)

### Added

* To create plan with attribute :api_created
* Actualize rubocop configs and add it's extensions
* Add `rubocop` check to CI
* Add `markdownlint` check in CI
* Add `.bundle` folder to `gitignore`
* Add development run instructions
* Add base Docker image config to `dependabot`
* Add `ruby-3.1` and `ruby-head` to CI
* Added `yamllint` support in CI
* Add `ruby-3.2` to CI
* Add `ruby-3.3` to CI
* Add `dependabot` check for `GitHub Actions`
* Reading product version from file, instead of hardcoded value
* Add GET `public/version` - to get version of application, in addition to POST
* Add new release flow to docs and rake task

### Changed

* Database scheme for simplification in future
* Actualize dependabot config
* Use `palladium` from gem, not from git sources
* Fix different typos in all parts of project
* Cleanup `Dockerfile`
* Correct logging to `STDOUT` for Docker usage
* Cleanup unused constants in `static_data.rb`
* Remove `AbstractProduct#is_archived` since it has no usage and not implemented
* Move `test` and `development` dependencies in correct Gemfile group
* Use `alpine` as base of Docker image
* Minor style fixes from `rubocop` v1.21.0
* Remove `travis-ci` config, since it replaced by Github Actions
* Configure `markdownlint` in CI via `linting.yml`
* Check `dependabot` at 8:00 Moscow time daily
* Fix `rubocop-1.28.1` code issues
* `ruby-3.0` is not supported any more
* Migrate base Dockerfile to `ruby-3.3`
* Fix `rubocop-1.68.0` code issues

### Fixed

* Fix `AbstractProductPack#diff` for created product
* Fix old version of `nodejs` in CI

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
