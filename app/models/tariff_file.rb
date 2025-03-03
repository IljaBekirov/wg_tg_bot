# frozen_string_literal: true

class TariffFile < ApplicationRecord
  has_one :order
  belongs_to :tariff, optional: true
  belongs_to :user, optional: true
  has_one_attached :file

  scope :unsent, -> { where(sent: false) }

  before_save :set_send_at, if: :sent_changed?

  validates :file, presence: true
  # validates :tariff_id, presence: true
  validate :file_attached?

  private

  def file_attached?
    errors.add(:file, 'должен быть прикреплен') unless file.attached?
  end

  def set_send_at
    self.send_at = Time.current if sent?
  end
end
