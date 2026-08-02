# frozen_string_literal: true

server '148.222.186.245', user: 'root', roles: %w[app]

set :ssh_options, verify_host_key: :never
