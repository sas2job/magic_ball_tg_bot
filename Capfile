# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/asdf'

Dir.glob('lib/capistrano/tasks/*.rake').sort.each { |rake| import rake }
