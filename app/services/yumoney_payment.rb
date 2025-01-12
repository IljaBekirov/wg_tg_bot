# frozen_string_literal: true

require 'faraday'
require 'json'

class YumoneyPayment
  YUMONEY_API_URL = 'https://api.yookassa.ru/v3/payments'

  def initialize(order, confirmation_type)
    @order = order
    @shop_id = ENV['YUMONEY_SHOP_ID']
    @secret_key = ENV['YUMONEY_SECRET_KEY']
    @confirmation_type = confirmation_type
  end

  def create_payment
    payment_data = {
      amount: {
        value: format('%.2f', @order.amount / 100.0),
        currency: 'RUB'
      },
      confirmation: confirmation_data,
      description: "Оплата заказа №#{@order.id}",
      capture: true,
      metadata: { order_id: @order.id }
    }

    response = Faraday.post(
      YUMONEY_API_URL,
      payment_data.to_json,
      headers
    )

    handle_response(JSON.parse(response.body))
  end

  private

  def confirmation_data
    case @confirmation_type
    when 'redirect'
      { type: 'redirect', return_url: "https://your-domain.com/success?order_id=#{@order.id}" }
    when 'qr'
      { type: 'qr' }
    when 'app'
      { type: 'mobile_application', return_url: "https://your-domain.com/success?order_id=#{@order.id}" }
    else
      raise 'Unsupported confirmation type'
    end
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Basic #{Base64.strict_encode64("#{@shop_id}:#{@secret_key}")}"
    }
  end

  def handle_response(response_body)
    if response_body['status'] == 'pending' && response_body['confirmation']
      {
        status: :pending,
        confirmation_url: response_body['confirmation']['confirmation_url'],
        confirmation_type: @confirmation_type,
        payment_id: response_body['id']
      }
    else
      { status: :error, error_message: response_body['description'] || 'Payment creation failed' }
    end
  end
end
