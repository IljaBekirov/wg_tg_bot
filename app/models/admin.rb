# frozen_string_literal: true

class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
end
