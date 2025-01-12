class CreateTariffFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :tariff_files do |t|
      t.text :content
      t.boolean :sent
      t.references :tariff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
