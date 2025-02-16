class CreateTariffs < ActiveRecord::Migration[7.1]
  def change
    create_table :tariffs do |t|
      t.integer :duration
      t.decimal :price
      t.string :description

      t.timestamps
    end
  end
end
