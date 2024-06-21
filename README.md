# palladium-api

[![Build Status](https://travis-ci.org/flaminestone/palladium-api.svg?branch=master)](https://travis-ci.org/flaminestone/palladium-api)

## How to run locally

1. Start temp postgresql db via
  `docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 postgres`
2. Either:

- `bundle exec rackup -p 9292`  
- Execute `config.ru` in debug\run mode in RubyMine

## How to release new version (for maintainers)

1. Update `VERSION` file
2. Update `CHANGELOG.md` by adding version line after `master (unreleased)`
3. Create PR with those changes and merge to `master`
4. On `master` run `rake add_repo_tag`
5. On `GitHub` create new release via web-browser and add info from `CHANGELOG.md`
