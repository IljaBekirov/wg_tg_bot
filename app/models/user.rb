class User < ApplicationRecord
  validates :telegram_chat_id, presence: true, uniqueness: true
end
