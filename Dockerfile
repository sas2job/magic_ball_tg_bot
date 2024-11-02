FROM ruby:3.3.2-alpine

RUN apk update && apk upgrade
RUN apk add --no-cache \
  build-essential \
  libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . /app

CMD ["ruby", "main.rb"]
