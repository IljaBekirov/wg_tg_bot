# frozen_string_literal: true

require 'telegram/bot'

class TelegramBot
  def initialize
    # puts 'Инициализация бота'
    # puts "Токен: #{ENV['TELEGRAM_BOT_TOKEN']}"
    # puts "secret_key_base: #{Rails.application.secrets.secret_key_base}"
    # puts "secret_key_base: #{ENV['SECRET_KEY_BASE']}"
    @bot = Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
    set_bot_commands
    puts 'Бот инициализирован'
    # puts @bot.inspect
  end

  def set_bot_commands
    commands = [
      { command: 'start', description: 'Запустить бота' },
      { command: 'keys', description: 'Мои ключи' },
      { command: 'pay', description: 'Заросить на вывод' }
    ]
    @bot.api.set_my_commands(commands: commands)
  rescue StandardError => e
    Rails.logger.error("Ошибка установки команд бота: #{e.message}")
  end

  def start
    @bot.listen do |message|
      puts "Получено сообщение: #{message.text}. Дата: #{DateTime.now}" if message.respond_to?(:text)

      case message
      when Telegram::Bot::Types::CallbackQuery
        CallbackQueryHandler.new(@bot, message).handle
      when Telegram::Bot::Types::Message
        MessageHandler.new(@bot, message).handle
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      if e.message.include?('403') && e.message.include?('bot was blocked')
        puts "Пользователь с chat_id=#{message.chat.id} заблокировал бота"
      else
        puts "Ошибка: #{e.message}"
        raise e
      end
    end
  end

  def notify_user(order)
    tariff_file = order.tariff_file

    return send_message(order.telegram_user_id, 'Файл не найден.') unless tariff_file&.file&.attached?

    file_data = tariff_file.file.download
    file = StringIO.new(file_data)

    send_document(order.telegram_user_id, file, tariff_file.file.filename.to_s)
  end

  private

  def send_message(chat_id, text)
    @bot.api.send_message(chat_id: chat_id, text: text)
  end

  def send_document(chat_id, file, filename)
    @bot.api.send_document(
      chat_id: chat_id,
      document: Faraday::UploadIO.new(file, 'text/plain', filename),
      caption: 'Ваш файл успешно отправлен. Спасибо за оплату!'
    )
  rescue StandardError => e
    Rails.logger.error("Ошибка отправки файла в Telegram: #{e.message}")
    false
  end
end
