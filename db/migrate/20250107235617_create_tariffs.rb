class CreateTariffs < ActiveRecord::Migration[7.1]
  def change
    create_table :tariffs do |t|
      t.string :name
      t.decimal :price
      t.string :file_path

      t.timestamps
    end
  end
end
