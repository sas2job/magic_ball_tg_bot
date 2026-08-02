# frozen_string_literal: true

lock '~> 3.20.1'

set :application, 'magic_ball_tg_bot'
set :repo_url, 'git@github.com:sas2job/magic_ball_tg_bot.git'
set :branch, 'master'
set :deploy_to, '/home/deploy/projects/magic_ball_tg_bot'
set :format, :airbrussh
set :pty, true
set :keep_releases, 5
set :asdf_ruby_version, '4.0.6'

append :linked_files, '.env'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache'

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

        command = <<~CMD
          set -e
          pid_file=/tmp/magic_ball_tg_bot.pid
          if [ -f "$pid_file" ]; then
            old_pid=$(cat "$pid_file")
            if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
              kill "$old_pid" || true
              sleep 2
            fi
          fi

          mkdir -p #{shared_path}/log
          nohup bundle exec ruby main.rb > #{shared_path}/log/bot.log 2>&1 &
        CMD

        execute :bash, '-lc', command
      end
    end
  end
end

after 'deploy:published', 'bot:restart'
