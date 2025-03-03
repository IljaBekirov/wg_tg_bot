class AddUserIdToTariffFiles < ActiveRecord::Migration[7.1]
  def change
    add_reference :tariff_files, :user, foreign_key: true
    add_column :tariff_files, :enabled, :boolean
  end
end
