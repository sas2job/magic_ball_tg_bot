# frozen_string_literal: true

lock '~> 3.20.1'

set :application, 'magic_ball_tg_bot'
set :repo_url, 'git@github.com:sas2job/magic_ball_tg_bot.git'
set :branch, 'master'
set :deploy_to, '/home/deploy/projects/magic_ball_tg_bot'
set :format, :airbrussh
set :pty, true
set :keep_releases, 5
set :bundle_env_variables, {
  'ASDF_DIR' => '/home/deploy/.asdf',
  'PATH' => '/home/deploy/.asdf/shims:/home/deploy/.asdf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
}
set :default_env, {
  'ASDF_DIR' => '/home/deploy/.asdf',
  'PATH' => '/home/deploy/.asdf/shims:/home/deploy/.asdf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
}

append :linked_files, '.env'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache'

namespace :asdf do
  desc 'Install ASDF tool versions for the current release'
  task :install do
    on roles(:app) do
      within release_path do
        execute "bash -c 'source /home/deploy/.asdf/asdf.sh && asdf install'"
      end
    end
  end
end

namespace :bot do
  desc 'Restart the bot after deploy'
  task :restart do
    on roles(:app) do
      within release_path do
        env_file = shared_path.join('.env')
        unless test("[ -f #{env_file} ] && grep -Eq '^BOT_TOKEN=.+$' #{env_file}")
          info 'Skipping bot restart because BOT_TOKEN is not configured in shared/.env'
          next
        end

        execute :bash, 'bin/restart_bot.sh'
      end
    end
  end
end

before 'bundler:config', 'asdf:install'
after 'deploy:published', 'bot:restart'
