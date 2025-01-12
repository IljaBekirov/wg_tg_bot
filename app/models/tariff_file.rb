class TariffFile < ApplicationRecord
  belongs_to :tariff

  scope :unsent, -> { where(sent: false) }

  validates :content, presence: true
end
