class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :telegram_chat_id
      t.string :username
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
