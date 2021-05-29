FROM ruby:2.6.3
ENV RACK_ENV=production
RUN mkdir /palladium-api
WORKDIR /palladium-api
ADD . /palladium-api
RUN gem update bundler
RUN bundle config set --local with 'server'
RUN bundle install