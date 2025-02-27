# frozen_string_literal: true

class User < ApplicationRecord
  validates :telegram_chat_id, presence: true, uniqueness: true
  has_many :orders
end
