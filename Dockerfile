FROM ruby:3.3.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . /app

CMD ["ruby", "main.rb"]
