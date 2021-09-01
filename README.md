# palladium-api

[![Build Status](https://travis-ci.org/flaminestone/palladium-api.svg?branch=master)](https://travis-ci.org/flaminestone/palladium-api)


## How to run locally

1. Start temp postgresql db via `docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 postgres`
2. Either:
- `bundle exec rackup -p 9292`  
- Execute `config.ru` in debug\run mode in RubyMine

