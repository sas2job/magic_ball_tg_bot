require 'dotenv'
Dotenv.load
require 'telegram/bot'
TOKEN = ENV['TOKEN']

# Массив с ответами
ANSWERS = [
  # Положительные
  "It is certain (Бесспорно)",
  "It is decidedly so (Предрешено)",
  "Without a doubt (Никаких сомнений)",
  "Yes — definitely (Определённо да)",
  "You may rely on it (Можешь быть уверен в этом)",
  # Нерешительно положительные
  "As I see it, yes (Мне кажется — «да»)",
  "Most likely (Вероятнее всего)",
  "Outlook good (Хорошие перспективы)",
  "Signs point to yes (Знаки говорят — «да»)",
  "Yes (Да)",
  # Нейтральные
  "Reply hazy, try again (Пока не ясно, попробуй снова)",
  "Ask again later (Спроси позже)",
  "Better not tell you now (Лучше не рассказывать)",
  "Cannot predict now (Сейчас нельзя предсказать)",
  "Concentrate and ask again (Сконцентрируйся и спроси опять)",
  # Отрицательные
  "Don’t count on it (Даже не думай)",
  "My reply is no (Мой ответ — «нет»)",
  "My sources say no (По моим данным — «нет»)",
  "Outlook not so good (Перспективы не очень хорошие)",
  "Very doubtful (Весьма сомнительно)"
]

def send_message(bot, chat_id, text)
  begin
    bot.api.send_message(chat_id: chat_id, text: text)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if e.error_code == 429
      retry_after = e.parameters['retry_after'].to_i
      puts "Too many requests. Retrying after #{retry_after} seconds."
      sleep(retry_after)
      retry
    else
      puts "An error occurred: #{e.message}"
    end
  end
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |update|
    if update.is_a?(Telegram::Bot::Types::Message) && update.text
      case update.text
      when '/start', '/start start'
        send_message(
          bot, update.chat.id,
          "Hello, #{update.from.first_name}. " \
          "It's a magic ball. Ask it a question and you'll get the answer."
        )
      else
        sleep(15)
        send_message(bot, update.chat.id, ANSWERS.sample)
      end
    else
      puts "Received an update of type: #{update.class}"
    end
  end
end
