FROM ruby:3.3.2-alpine

RUN apk add --no-cache build-base

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . /app

CMD ["ruby", "main.rb"]
