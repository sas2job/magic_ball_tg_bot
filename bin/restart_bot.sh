#!/usr/bin/env bash
set -euo pipefail

source /home/deploy/.asdf/asdf.sh

pid_file=/tmp/magic_ball_tg_bot.pid
log_dir=/home/deploy/projects/magic_ball_tg_bot/shared/log
bot_cmd='bundle exec ruby main.rb'

if [[ -f "$pid_file" ]]; then
  old_pid=$(cat "$pid_file")
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" || true
    sleep 2
  fi
fi

mkdir -p "$log_dir"
setsid -f sh -c "cd /home/deploy/projects/magic_ball_tg_bot/current && exec $bot_cmd" \
  >> "$log_dir/bot.log" 2>&1 < /dev/null

for _ in 1 2 3 4 5; do
  pid=$(pgrep -n -f "$bot_cmd" || true)
  if [[ -n "$pid" ]]; then
    echo "$pid" > "$pid_file"
    exit 0
  fi
  sleep 1
done

echo "Failed to start bot process" >&2
exit 1
