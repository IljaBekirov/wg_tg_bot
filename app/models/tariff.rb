class Tariff < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :tariff_files, dependent: :destroy

  validates :name, :price, presence: true
end
