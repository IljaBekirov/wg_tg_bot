# frozen_string_literal: true

require 'httparty'
require 'redis'

class WireguardService
  include HTTParty

  class WireguardServiceError < StandardError; end
  class AlreadyLoggedInError < WireguardServiceError; end
  class NotLoggedInError < WireguardServiceError; end

  def initialize(url, password, session_cache: SessionCache.new)
    @url = url
    @password = password
    @session_cache = session_cache
    @session = @session_cache.load_session || HTTParty::CookieHash.new
  end

  def logged_in?
    session_data['authenticated']
  rescue StandardError => e
    raise WireguardServiceError, "Failed to check login status: #{e.message}"
  end

  def login
    response = post_request('/session', body: { password: @password })
    @session.add_cookies(response.headers['set-cookie'])
    @session_cache.save_session(@session)
  end

  def logout
    raise NotLoggedInError, 'You are not logged in' unless logged_in?

    delete_request('/session')
    @session_cache.clear_session
  end

  def get_clients
    get_request('/wireguard/client')
  end

  def get_client(uid)
    get_clients.find { |client| client['uid'] == uid }
  end

  def find_client_by_name(name)
    clients = get_clients
    clients&.find { |client| client['name'] == name }
  end

  def create_client(name)
    post_request('/wireguard/client', body: { name: name })
  end

  def remove_client(uid)
    delete_request("/wireguard/client/#{uid}")
  end

  def qr_code(uid)
    get_request("/wireguard/client/#{uid}/qrcode.svg")
  end

  def configuration(uid)
    get_request("/wireguard/client/#{uid}/configuration")
  end

  def update_name(uid, name)
    put_request("/wireguard/client/#{uid}/name", body: { name: name })
  end

  def enable_client(uid)
    post_request("/wireguard/client/#{uid}/enable")
  end

  def disable_client(uid)
    post_request("/wireguard/client/#{uid}/disable")
  end

  private

  def session_data
    get_request('/session')
  end

  def get_request(path)
    handle_request_errors { self.class.get(url_builder(path), headers: request_headers) }
  end

  def post_request(path, body: {})
    handle_request_errors do
      self.class.post(
        url_builder(path),
        body: body.to_json,
        headers: request_headers('Content-Type' => 'application/json')
      )
    end
  end

  def put_request(path, body: {})
    handle_request_errors do
      self.class.put(
        url_builder(path),
        body: body.to_json,
        headers: request_headers('Content-Type' => 'application/json')
      )
    end
  end

  def delete_request(path)
    handle_request_errors { self.class.delete(url_builder(path), headers: request_headers) }
  end

  def handle_request_errors
    yield
  rescue StandardError => e
    raise WireguardServiceError, "#{e.class} request failed: #{e.message}"
  end

  def url_builder(path)
    "#{@url}#{path}"
  end

  def request_headers(additional_headers = {})
    { 'Cookie' => @session.to_cookie_string }.merge(additional_headers)
  end
end

class SessionCache
  def initialize
    @redis = Redis.new(url: ENV['REDIS_URL'], password: ENV['REDIS_PASSWORD'])
    @session_key = 'wireguard_service:session'
  end

  def load_session
    cached_session = @redis.get(@session_key)
    return nil unless cached_session

    parsed_cookies = JSON.parse(cached_session)
    cookie_hash = HTTParty::CookieHash.new
    parsed_cookies.each { |key, value| cookie_hash.add_cookies("#{key}=#{value}") }

    cookie_hash
  end

  def save_session(session)
    cookies_hash = session.to_hash
    @redis.set(@session_key, cookies_hash.to_json)
  end

  def clear_session
    @redis.del(@session_key)
  end
end
