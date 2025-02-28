# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :tariff_file, optional: true
  belongs_to :tariff
  belongs_to :user

  validates :telegram_user_id, :amount, :status, presence: true
end
