# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby '4.0.6'

gem 'dotenv', '3.1.4'
gem 'telegram-bot-ruby', '~> 2.7'

group :development do
  gem 'capistrano', '~> 3.20', require: false
  gem 'capistrano-asdf', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 2.2', require: false
  gem 'bcrypt_pbkdf', '~> 1.1', require: false
  gem 'ed25519', '~> 1.4', require: false
end
