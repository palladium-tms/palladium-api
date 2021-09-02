FROM ruby:3.0.2-alpine

ENV RACK_ENV=production

RUN apk add build-base \
            postgresql-dev
ADD . /palladium-api
WORKDIR /palladium-api

RUN gem update bundler
RUN bundle config set without 'development test' && \
    bundle install

CMD ["bundle", "exec", "puma"]
