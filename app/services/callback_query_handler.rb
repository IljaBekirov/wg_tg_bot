# frozen_string_literal: true

class CallbackQueryHandler
  def initialize(bot, query)
    @bot = bot
    @query = query
  end

  def handle
    case @query.data
    when /^tariff_/ then handle_tariff_selection
    when /^tfile_/ then handle_tfile
    # when /^confirm_/ then handle_payment_confirmation
    # when /^check_payment_/ then handle_payment_check
    else send_message('Неизвестный выбор.')
    end

    @bot.api.answer_callback_query(callback_query_id: @query.id)
  end

  private

  def handle_tariff_selection
    tariff = Tariff.find_by(id: extract_id(@query.data))
    return send_message('Тариф не найден.') unless tariff

    user = User.find_by(telegram_chat_id: @query.message.chat.id)
    order = create_order(user, tariff)
    payment_response = YumoneyPayment.new(order).create_payment
    order.update(payment_id: payment_response[:payment_id])
    send_payment_message(tariff, payment_response[:confirmation_url])
  end

  def handle_tfile
    tariff_file = TariffFile.find(extract_id(@query.data))

    send_message("Тариф файл найден: #{tariff_file.wg_uuid}")
  end

  def create_order(user, tariff)
    Order.create(
      telegram_user_id: @query.message.chat.id,
      user_id: user.id,
      tariff: tariff,
      amount: tariff.price,
      status: 'pending'
    )
  end

  def send_payment_message(tariff, url)
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: 'Оплатить', url: url
          )
        ]
      ]
    )
    send_message(build_message_text(tariff), markup)
  end

  def send_message(text, markup = nil)
    @bot.api.send_message(chat_id: @query.message.chat.id, text:, reply_markup: markup)
  end

  def extract_id(data)
    data.split('_').last
  end

  def build_message_text(tariff)
    <<~MESSAGE
      Оплата подписки на "#{tariff.duration} мес - #{tariff.price} руб."

      Для оплаты откроется браузер.
      Вы сможете оплатить подписку с помощью банковских карт, СБП и SberPay.
    MESSAGE
  end
end
