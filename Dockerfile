FROM ruby:2.4.1
EXPOSE 80
ENV JWT_SECRET=someawesomesecret
ENV JWT_ISSUER=someawesomesecret
RUN mkdir /palladium
WORKDIR /palladium
ADD . /palladium
RUN bundle install --without test development
