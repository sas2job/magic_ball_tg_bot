#!/usr/bin/env bash
set -euo pipefail

source /home/deploy/.asdf/asdf.sh

log_dir=/home/deploy/projects/magic_ball_tg_bot/shared/log
pid_file=/tmp/magic_ball_tg_bot.pid
bot_cmd='bundle exec ruby main.rb'
bot_pid_pattern='ruby .*main[.]rb'

old_pids=$(pgrep -u "$(id -u)" -f "$bot_pid_pattern" || true)
if [[ -n "$old_pids" ]]; then
  kill $old_pids || true
  for _ in 1 2 3 4 5; do
    if ! pgrep -u "$(id -u)" -f "$bot_pid_pattern" > /dev/null; then
      break
    fi
    sleep 1
  done
fi

if pgrep -u "$(id -u)" -f "$bot_pid_pattern" > /dev/null; then
  echo "Failed to stop the previous bot process" >&2
  exit 1
fi

rm -f "$pid_file"

mkdir -p "$log_dir"
setsid -f sh -c "cd /home/deploy/projects/magic_ball_tg_bot/current && exec $bot_cmd" \
  >> "$log_dir/bot.log" 2>&1 < /dev/null

for _ in 1 2 3 4 5; do
  pid=$(cat "$pid_file" 2>/dev/null || true)
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    exit 0
  fi
  sleep 1
done

echo "Failed to start bot process" >&2
exit 1
