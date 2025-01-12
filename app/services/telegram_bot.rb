# frozen_string_literal: true

require 'telegram/bot'

class TelegramBot
  TOKEN = ENV['TELEGRAM_BOT_TOKEN']

  def self.listen
    Telegram::Bot::Client.run(TOKEN) do |bot|
      bot.listen do |message|
        puts "Получено сообщение: #{message.text}. Дата: #{DateTime.now}" if message.respond_to?(:text)

        case message
        when Telegram::Bot::Types::CallbackQuery
          CallbackQueryHandler.new(bot, message).handle
        when Telegram::Bot::Types::Message
          MessageHandler.new(bot, message).handle
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
  end

  def self.notify_user(order)
    tariff_file = order.tariff.tariff_files.find_by(sent: false)

    Telegram::Bot::Client.run(TOKEN) do |bot|
      if tariff_file
        file = Tempfile.new(%w[config .conf])
        file.write(tariff_file.content)
        file.rewind

        bot.api.send_document(
          chat_id: order.telegram_user_id,
          document: Faraday::UploadIO.new(file.path, 'text/plain', 'config.conf')
        )

        file.close
        file.unlink

        tariff_file.update(sent: true)
      else
        bot.api.send_message(chat_id: order.telegram_user_id, text: 'Файл не найден.')
      end
    end
  end
end
