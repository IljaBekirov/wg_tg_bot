# frozen_string_literal: true

class PaymentProcessor
  def initialize(payload, server_service)
    @payload = payload
    @server_service = server_service
  end

  def process
    return unless payment_succeeded?

    order = find_order
    return unless order

    update_order_and_tariff(order)
    notify_user(order)
  end

  private

  def payment_succeeded?
    @payload['event'] == 'payment.succeeded'
  end

  def find_order
    Order.find_by(id: @payload.dig('object', 'metadata', 'order_id'))
  end

  def update_order_and_tariff(order)
    tariff_file = TariffFile.find_by(sent: false)
    return unless tariff_file

    expired_at = calculate_expiration(order)

    ActiveRecord::Base.transaction do
      order.update!(status: 'paid', tariff_file: tariff_file)
      tariff_file.update!(
        sent: true,
        tariff: order.tariff,
        user: order.user,
        expired_at: expired_at
      )
    end

    update_server_expiration(tariff_file, expired_at)
  end

  def calculate_expiration(order)
    Time.current + order.tariff.duration.months
  end

  def update_server_expiration(tariff_file, expired_at)
    @server_service.update_expired_at(tariff_file.wg_uuid, expired_at)
  end

  def notify_user(order)
    TelegramBot.new.notify_user(order)
  end
end
