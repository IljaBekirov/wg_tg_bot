class TariffFile < ApplicationRecord
  belongs_to :tariff
  has_one_attached :file

  scope :unsent, -> { where(sent: false) }
end
