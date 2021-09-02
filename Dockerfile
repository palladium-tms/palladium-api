FROM ruby:3.0.2

ENV RACK_ENV=production

ADD . /palladium-api
WORKDIR /palladium-api

RUN gem update bundler
RUN bundle config set without 'development test' && \
    bundle install

CMD ["bundle", "exec", "puma"]
