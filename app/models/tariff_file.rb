class TariffFile < ApplicationRecord
  belongs_to :tariff
  has_one_attached :file

  scope :unsent, -> { where(sent: false) }

  validates :file, presence: true
  validates :tariff_id, presence: true
  validate :file_attached?

  private

  def file_attached?
    errors.add(:file, 'должен быть прикреплен') unless file.attached?
  end
end
