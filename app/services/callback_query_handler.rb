# frozen_string_literal: true

class CallbackQueryHandler
  def initialize(bot, query)
    @bot = bot
    @query = query
  end

  def handle
    case @query.data
    when /^tariff_/
      handle_tariff_selection
    when /^confirm_/
      handle_payment_confirmation
    when /^check_payment_/
      handle_payment_check
    else
      @bot.api.send_message(chat_id: @query.message.chat.id, text: 'Неизвестный выбор.')
    end

    @bot.api.answer_callback_query(callback_query_id: @query.id)
  end

  private

  def handle_tariff_selection
    tariff_id = @query.data.split('_').last
    tariff = Tariff.find_by(id: tariff_id)

    if tariff
      user = User.find_by(telegram_chat_id: @query.message.chat.id)
      order = Order.create(
        telegram_user_id: @query.message.chat.id,
        user_id: user.id,
        tariff:,
        amount: tariff.price,
        status: 'pending'
      )

      buttons = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Redirect', callback_data: "confirm_#{order.id}_redirect"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'QR', callback_data: "confirm_#{order.id}_qr"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Mobile Application',
                                                       callback_data: "confirm_#{order.id}_app")
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons.each_slice(2).to_a)

      @bot.api.send_message(
        chat_id: @query.message.chat.id,
        text: "Вы выбрали тариф:\n#{tariff.name}. Цена: #{tariff.price} руб.\nВыберите способ подтверждения платежа:",
        reply_markup: markup
      )
    else
      @bot.api.send_message(chat_id: @query.message.chat.id, text: 'Тариф не найден.')
    end
  end

  def handle_payment_confirmation
    _, order_id, confirmation_type = @query.data.split('_')
    order = Order.find_by(id: order_id)

    if order
      payment_service = YumoneyPayment.new(order, confirmation_type)
      payment_response = payment_service.create_payment

      if payment_response[:status] == :pending
        order.update(payment_id: payment_response[:payment_id])

        confirmation_message =
          case confirmation_type
          when 'redirect', 'mobile_application'
            "Для завершения оплаты перейдите по следующей ссылке: #{payment_response[:confirmation_url]}"
          when 'qr'
            "Для завершения оплаты просканируйте следующий QR-код: #{payment_response[:confirmation_url]}"
          else
            'Ошибка в выборе способа подтверждения.'
          end

        @bot.api.send_message(
          chat_id: @query.message.chat.id,
          text: confirmation_message
        )
      else
        @bot.api.send_message(
          chat_id: @query.message.chat.id,
          text: "Ошибка создания платежа: #{payment_response[:error_message]}"
        )
      end
    else
      @bot.api.send_message(chat_id: @query.message.chat.id, text: 'Заказ не найден.')
    end
  end

  def handle_payment_check
    order = Order.find_by(id: @query.data.split('_').last)

    if order
      process_payment_check(order)
    else
      send_message('Заказ не найден.')
    end
  end

  def process_payment_check(order)
    payment_service = YumoneyPayment.new(order, nil)
    payment_status = payment_service.check_payment_status

    if payment_status == 'succeeded'
      handle_successful_payment(order)
    else
      send_message('Оплата еще не завершена или произошла ошибка. Попробуйте снова позже.')
    end
  end

  def handle_successful_payment(order)
    order.update(status: 'paid')
    file = order.tariff.tariff_files.find_by(sent: false)

    if file
      send_document(file)
      file.update(sent: true)
    else
      send_message('Файлы для этого тарифа закончились. Свяжитесь с поддержкой.')
    end
  end

  def send_document(file)
    @bot.api.send_document(
      chat_id: @query.message.chat.id,
      document: Faraday::UploadIO.new(file.path, 'text/plain'),
      caption: 'Ваш файл успешно отправлен. Спасибо за оплату!'
    )
  end

  def send_message(text)
    @bot.api.send_message(chat_id: @query.message.chat.id, text:)
  end
end
