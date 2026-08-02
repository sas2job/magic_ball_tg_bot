#!/usr/bin/env bash
set -euo pipefail

source /home/deploy/.asdf/asdf.sh

pid_file=/tmp/magic_ball_tg_bot.pid
log_dir=/home/deploy/projects/magic_ball_tg_bot/shared/log

if [[ -f "$pid_file" ]]; then
  old_pid=$(cat "$pid_file")
  if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" || true
    sleep 2
  fi
fi

mkdir -p "$log_dir"
nohup bundle exec ruby main.rb > "$log_dir/bot.log" 2>&1 &
echo $! > "$pid_file"
