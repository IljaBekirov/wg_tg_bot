# frozen_string_literal: true

class RemoveTariffReferenceFromTariffFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :tariff_files, :send_at, :datetime
    change_column_null :tariff_files, :tariff_id, true
    add_reference :orders, :tariff_file, null: true, foreign_key: true
  end
end
