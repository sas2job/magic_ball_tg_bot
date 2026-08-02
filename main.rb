require 'dotenv'
Dotenv.load
require 'telegram/bot'
require 'set'

TOKEN = ENV['BOT_TOKEN']
LOCK_FILE = '/tmp/magic_ball_tg_bot.pid'
UNSUPPORTED_CHAT_IDS = Set.new
SUPPORTED_CHAT_TYPES = %w[private group supergroup].freeze
MAGIC_BALL_RETRY_SECONDS = 15
DEFAULT_ERROR_RETRY_SECONDS = 3
RATE_LIMIT_RETRY_FLOOR = 1
BOT_START_COMMANDS = ['/start', '/start start'].freeze
BOT_SHAKE_COMMANDS = ['Встряхнуть бота', 'Shake the bot'].freeze
BOT_START_MESSAGE = "Hello, %{name}. It's a magic ball. Ask it a question or shake the bot!"

ANSWERS = [
  "It is certain (Бесспорно)",
  "It is decidedly so (Предрешено)",
  "Without a doubt (Никаких сомнений)",
  "Yes — definitely (Определённо да)",
  "You may rely on it (Можешь быть уверен в этом)",
  "As I see it, yes (Мне кажется — «да»)",
  "Most likely (Вероятнее всего)",
  "Outlook good (Хорошие перспективы)",
  "Signs point to yes (Знаки говорят — «да»)",
  "Yes (Да)",
  "Reply hazy, try again (Пока не ясно, попробуй снова)",
  "Ask again later (Спроси позже)",
  "Better not tell you now (Лучше не рассказывать)",
  "Cannot predict now (Сейчас нельзя предсказать)",
  "Concentrate and ask again (Сконцентрируйся и спроси опять)",
  "Don’t count on it (Даже не думай)",
  "My reply is no (Мой ответ — «нет»)",
  "My sources say no (По моим данным — «нет»)",
  "Outlook not so good (Перспективы не очень хорошие)",
  "Very doubtful (Весьма сомнительно)"
].freeze

def retry_after_seconds(error, default_seconds)
  retry_after = error.parameters&.[]('retry_after').to_i
  retry_after.positive? ? retry_after : default_seconds
end

def telegram_response_error?(error)
  error.is_a?(Telegram::Bot::Exceptions::ResponseError)
end

def send_message(bot, chat_id, text, reply_markup = nil)
  begin
    bot.api.send_message(chat_id: chat_id, text: text, reply_markup: reply_markup)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if e.error_code == 429
      retry_after = retry_after_seconds(e, RATE_LIMIT_RETRY_FLOOR)
      puts "Too many requests. Retrying after #{retry_after} seconds."
      sleep(retry_after)
      retry
    else
      puts "An error occurred: #{e.message}"
    end
  end
end

def supported_chat?(message)
  SUPPORTED_CHAT_TYPES.include?(message.chat&.type)
end

def log_unsupported_chat_once(message)
  chat_id = message.chat&.id
  chat_type = message.chat&.type
  key = "#{chat_type}:#{chat_id}"
  return if UNSUPPORTED_CHAT_IDS.include?(key)

  UNSUPPORTED_CHAT_IDS.add(key)
  puts "Skipping unsupported chat type: #{chat_type} (chat_id=#{chat_id})"
end

def start_keyboard
  Telegram::Bot::Types::ReplyKeyboardMarkup.new(
    keyboard: [[
      Telegram::Bot::Types::KeyboardButton.new(text: 'Встряхнуть бота'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'Shake the bot')
    ]],
    one_time_keyboard: true,
    resize_keyboard: true
  )
end

def start_message(first_name)
  format(BOT_START_MESSAGE, name: first_name)
end

def answer_message
  ANSWERS.sample
end

def bot_process_pid?(pid)
  cmdline = File.binread("/proc/#{pid}/cmdline").tr("\0", ' ').strip
  return false if cmdline.empty?

  cmdline.include?('ruby') && cmdline.include?('main.rb')
rescue Errno::ENOENT, Errno::EACCES
  false
end

def bot_process_running?(pid)
  Process.kill(0, pid)
  bot_process_pid?(pid)
rescue Errno::ESRCH
  false
rescue Errno::EPERM
  # Process exists but we do not have signal permission; rely on cmdline check.
  bot_process_pid?(pid)
end

def with_single_instance_lock
  pid = Process.pid

  if File.exist?(LOCK_FILE)
    existing_pid = File.read(LOCK_FILE).strip.to_i
    if existing_pid.positive?
      if bot_process_running?(existing_pid)
        puts "Another local bot instance is already running (pid=#{existing_pid})."
        puts "Stop it and run again: kill #{existing_pid}"
        exit(1)
      end
    end
  end

  File.write(LOCK_FILE, pid)

  begin
    yield
  ensure
    if File.exist?(LOCK_FILE) && File.read(LOCK_FILE).strip == pid.to_s
      File.delete(LOCK_FILE)
    end
  end
end

def handle_polling_conflict(error)
  return false unless telegram_response_error?(error)
  return false unless error.error_code == 409

  puts 'Telegram polling conflict (409): another bot instance is already calling getUpdates.'
  puts 'Make sure only one process/container uses this BOT_TOKEN at a time.'
  puts "Waiting #{MAGIC_BALL_RETRY_SECONDS} seconds before retrying polling."
  sleep(MAGIC_BALL_RETRY_SECONDS)
  true
end

def handle_polling_error(error)
  return false unless telegram_response_error?(error)

  return true if handle_polling_conflict(error)

  case error.error_code
  when 429
    retry_after = retry_after_seconds(error, RATE_LIMIT_RETRY_FLOOR)
    puts "Polling rate limit (429). Retrying after #{retry_after} seconds."
    sleep(retry_after)
    true
  when 502
    puts 'Telegram temporary error (502). Retrying after 3 seconds.'
    sleep(DEFAULT_ERROR_RETRY_SECONDS)
    true
  else
    puts "Polling error (#{error.error_code}): #{error.message}"
    sleep(DEFAULT_ERROR_RETRY_SECONDS)
    true
  end
end

def handle_message_update(bot, update)
  unless supported_chat?(update)
    log_unsupported_chat_once(update)
    return
  end

  case update.text
  when *BOT_START_COMMANDS
    send_message(bot, update.chat.id, start_message(update.from.first_name), start_keyboard)
  when *BOT_SHAKE_COMMANDS
    send_message(bot, update.chat.id, answer_message)
  else
    sleep(MAGIC_BALL_RETRY_SECONDS)
    send_message(bot, update.chat.id, answer_message)
  end
end

def process_update(bot, update)
  if update.is_a?(Telegram::Bot::Types::Message)
    handle_message_update(bot, update)
  else
    puts "Received an update of type: #{update.class}"
  end
end

with_single_instance_lock do
  Telegram::Bot::Client.run(TOKEN, allowed_updates: %w[message]) do |bot|
    loop do
      begin
        bot.listen { |update| process_update(bot, update) }
      rescue Telegram::Bot::Exceptions::ResponseError => e
        raise unless handle_polling_error(e)
      rescue StandardError => e
        puts "Unexpected polling error: #{e.class}: #{e.message}"
        sleep(3)
      end
    end
  end
end
