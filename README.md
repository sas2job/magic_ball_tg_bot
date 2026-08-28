# magic_ball_tg_bot
Телеграмм бот "Волшебный шар" на Ruby

1. Склонируйте репозиторий и перейдите в него 
```console
git clone git@github.com:sas2job/magic_ball_tg_bot.git
cd magic_ball_tg_bot
```

3. Скопируйте `env` файл:
```console
$ cp .env.sample .env
```
и сохраните свое значение `BOT_TOKEN`

4. Создайте контейнер
```console
$ docker compose build
```
5. Запускаем контейнер
```console
$ docker compose up
```
6. Просмотр логов
```console
$ docker compose up
```
5. Остановка контейнера
```console
$ docker-compose down
```

## Deploy with Capistrano

### Local
```console
bundle install
bundle exec cap production deploy
```

### Server
- деплой выполняется под пользователем `deploy`
- `asdf` находится в `/home/deploy/.asdf`
- проект выкладывается в `/home/deploy/projects/magic_ball_tg_bot`
- для запуска нужен `/home/deploy/projects/magic_ball_tg_bot/shared/.env` с `BOT_TOKEN`
- после деплоя бот запускается через `bin/restart_bot.sh`

### Notes
- в проекте используется Ruby `4.0.6`
- `dotenv` должен быть доступен в production bundle
- если бот не отвечает, проверьте `/home/deploy/projects/magic_ball_tg_bot/shared/log/bot.log`
