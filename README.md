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