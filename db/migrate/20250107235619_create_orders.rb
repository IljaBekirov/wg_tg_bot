class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.string :status
      t.integer :telegram_user_id
      t.references :tariff, null: false, foreign_key: true
      t.integer :amount
      t.string :payment_id

      t.timestamps
    end
  end
end
