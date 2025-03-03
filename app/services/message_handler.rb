# frozen_string_literal: true

class MessageHandler
  def initialize(bot, message)
    @bot = bot
    @message = message
  end

  def handle
    find_or_create_user
    case @message.text
    when '/start'
      send_tariffs(user)
      send_tariffs
    when '/keys'
      check_keys
    else
      @bot.api.send_message(chat_id: @message.chat.id, text: 'Неизвестная команда.')
    end
  end

  private

  def check_keys
    tariff_files = User.find_by(telegram_chat_id: @message.from.id).tariff_files


    buttons = tariff_files.map do |tariff_file|
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: TariffFiles::Presenter.new(tariff_file).build_text_key,
        callback_data: "tfile_#{tariff_file.id}"
      )
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons.each_slice(1).to_a)

    @bot.api.send_message(
      chat_id: @message.chat.id,
      text: 'Ваши ключи',
      reply_markup: markup,
      parse_mode: 'HTML',
      disable_web_page_preview: true
    )
  end

  def find_or_create_user
    User.find_or_create_by(telegram_chat_id: @message.chat.id) do |u|
      u.username = @message.from.username
      u.first_name = @message.from.first_name
      u.last_name = @message.from.last_name
    end
  end

  def send_tariffs(user)
  def send_tariffs
    buttons = Tariff.all.order(:duration).map do |tariff|
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: build_tariff_message_text(tariff),
        callback_data: "tariff_#{tariff.id}"
      )
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons.each_slice(1).to_a)

    @bot.api.send_message(
      chat_id: @message.chat.id,
      text: build_message_text,
      reply_markup: markup,
      parse_mode: 'HTML',
      disable_web_page_preview: true
    )
  end

  def build_message_text
    <<~MESSAGE
      Оплатить подписку можно банковской картой

      Оплата производится официально через сервис ЮКасса
      Мы не сохраняем, не передаем и не имеем доступа к данным карт, используемых для оплаты

      <a href="https://telegra.ph/Publichnaya-oferta-02-08-4">Условия использования</a>

      Выберите период, на который хотите приобрести подписку:
    MESSAGE
  end

  def build_tariff_message_text(tariff)
    "#{tariff.duration} мес - #{tariff.price} руб. #{tariff.description}"
  end
end
