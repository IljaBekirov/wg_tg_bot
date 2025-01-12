class Order < ApplicationRecord
  belongs_to :tariff

  validates :telegram_user_id, :amount, :status, presence: true
end
