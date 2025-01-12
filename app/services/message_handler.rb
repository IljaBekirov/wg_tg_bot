# frozen_string_literal: true

class MessageHandler
  def initialize(bot, message)
    @bot = bot
    @message = message
  end

  def handle
    user = find_or_create_user

    case @message.text
    when '/start'
      send_tariffs(user)
    else
      @bot.api.send_message(chat_id: @message.chat.id, text: 'Неизвестная команда.')
    end
  end

  private

  def find_or_create_user
    User.find_or_create_by(telegram_chat_id: @message.chat.id) do |u|
      u.username = @message.from.username
      u.first_name = @message.from.first_name
      u.last_name = @message.from.last_name
    end
  end

  def send_tariffs(user)
    buttons = Tariff.all.map do |tariff|
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "#{tariff.name} - #{tariff.price} руб.",
        callback_data: "tariff_#{tariff.id}"
      )
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons.each_slice(2).to_a)

    @bot.api.send_message(
      chat_id: @message.chat.id,
      text: "Привет, #{user.first_name}!\nВыбери тариф:",
      reply_markup: markup
    )
  end
end
