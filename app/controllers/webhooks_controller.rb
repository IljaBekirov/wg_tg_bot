# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_server_service

  def yumoney
    payload = parse_payload(request.body.read)
    return render_error('Invalid payload') unless payload

    Rails.logger.debug { "\n#{'@' * 20}\n#{payload.inspect}\n#{'@' * 20}" }
    PaymentProcessor.new(payload, @server_service).process
    render_success
  end

  private

  def parse_payload(body)
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end

  def render_success
    render json: { message: 'OK' }, status: :ok
  end

  def render_error(message)
    render json: { message: message }, status: :bad_request
  end
end
