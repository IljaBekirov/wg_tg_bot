class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def yumoney
    payload = JSON.parse(request.body.read)

    order = Order.find_by(id: payload['object']['metadata']['order_id'])

    if order && payload['event'] == 'payment.succeeded'
      order.update(status: 'paid')
      TelegramBot.notify_user(order)
    end

    render json: { message: 'OK' }, status: :ok
  end
end
