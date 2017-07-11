FROM ruby:2.4.1
EXPOSE 8080
ENV JWT_SECRET=someawesomesecret
ENV JWT_ISSUER=someawesomesecret
RUN mkdir /palladium-api
WORKDIR /palladium-api
ADD . /palladium-api
RUN bundle install --without test development
CMD puma
