FROM ruby:2.6.3

ENV RACK_ENV=production

ADD . /palladium-api
WORKDIR /palladium-api

RUN gem update bundler
RUN bundle config set without 'development' && \
    bundle install

CMD ["bundle", "exec", "puma"]
