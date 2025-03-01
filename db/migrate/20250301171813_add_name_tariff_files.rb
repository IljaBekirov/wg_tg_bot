# frozen_string_literal: true

class AddNameTariffFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :tariff_files, :name, :string
    add_column :tariff_files, :wg_uuid, :string
    add_column :tariff_files, :expired_at, :datetime
  end
end
