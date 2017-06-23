FROM ruby:2.3.0
EXPOSE 3000
ENV JWT_SECRET=someawesomesecret
ENV JWT_ISSUER=someawesomesecret
RUN mkdir /palladium
WORKDIR /palladium
ADD . /palladium
RUN bundle install --without test development
