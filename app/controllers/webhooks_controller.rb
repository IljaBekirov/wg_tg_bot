# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def yumoney
    payload = JSON.parse(request.body.read)
    puts '@' * 20
    puts payload.inspect
    puts '@' * 20

    order = Order.find_by(id: payload['object']['metadata']['order_id'])

    if order && payload['event'] == 'payment.succeeded'
      tariff_file = TariffFile.find_by(sent: false)
      order.update!(status: 'paid', tariff_file: tariff_file)
      TelegramBot.new.notify_user(order)
    end

    render json: { message: 'OK' }, status: :ok
  end
end
