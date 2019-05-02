class CreatePriceTables < ActiveRecord::Migration[5.2]
  def change
    create_table :price_tables do |t|
      t.string :user_id
      t.integer :buy_price
      t.integer :sell_price

      t.timestamps
    end
  end
end
