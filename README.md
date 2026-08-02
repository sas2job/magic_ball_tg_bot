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
- `asdf` ставится в `/root/.asdf`
- проект выкладывается в `/root/projects/magic_ball_tg_bot`
- для запуска нужен `/root/projects/magic_ball_tg_bot/shared/.env` с `BOT_TOKEN`
