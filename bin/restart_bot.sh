#!/usr/bin/env bash
set -euo pipefail

source /home/deploy/.asdf/asdf.sh

log_dir=/home/deploy/projects/magic_ball_tg_bot/shared/log
bot_cmd='bundle exec ruby main.rb'
bot_pid_pattern='bundle exec ruby main.rb'

old_pids=$(pgrep -f "$bot_pid_pattern" || true)
if [[ -n "$old_pids" ]]; then
  kill $old_pids || true
  sleep 2
fi

mkdir -p "$log_dir"
setsid -f sh -c "cd /home/deploy/projects/magic_ball_tg_bot/current && exec $bot_cmd" \
  >> "$log_dir/bot.log" 2>&1 < /dev/null

for _ in 1 2 3 4 5; do
  pid=$(pgrep -n -f "$bot_pid_pattern" || true)
  if [[ -n "$pid" ]]; then
    exit 0
  fi
  sleep 1
done

echo "Failed to start bot process" >&2
exit 1
