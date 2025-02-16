# frozen_string_literal: true

require 'faraday'
require 'json'

class YumoneyPayment
  YUMONEY_API_URL = 'https://api.yookassa.ru/v3/payments'
  TG_URL = 'https://t.me/wgtg_bot'

  def initialize(order)
    @order = order
  end

  def create_payment
    response = Faraday.post(YUMONEY_API_URL, payment_data.to_json, headers)
    handle_response(JSON.parse(response.body))
  end

  private

  def payment_data
    {
      amount: amount_data,
      confirmation: confirmation_data,
      description: payment_description,
      capture: true,
      metadata: { order_id: @order.id }
    }
  end

  def amount_data
    {
      value: format('%.2f', @order.amount),
      currency: 'RUB'
    }
  end

  def confirmation_data
    {
      type: 'redirect',
      return_url: TG_URL
    }
  end

  def payment_description
    "Оплата заказа №#{@order.id}"
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Idempotence-Key' => SecureRandom.uuid,
      'Authorization' => authorization_header
    }
  end

  def authorization_header
    "Basic #{Base64.strict_encode64("#{shop_id}:#{secret_key}")}"
  end

  def shop_id
    Rails.application.config.yumoney[:shop_id]
  end

  def secret_key
    Rails.application.config.yumoney[:secret_key]
  end

  def handle_response(response_body)
    if response_body['status'] == 'pending' && response_body['confirmation']
      {
        status: :pending,
        confirmation_url: response_body['confirmation']['confirmation_url'],
        payment_id: response_body['id']
      }
    else
      { status: :error, error_message: response_body['description'] || 'Payment creation failed' }
    end
  end
end
