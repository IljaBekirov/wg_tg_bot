# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  def set_server_service
    @server_service = WireguardService.new(ENV['SERVICE_URL'], ENV['SERVICE_PASSWORD'])
    @server_service.login unless @server_service.logged_in?
  end
end
