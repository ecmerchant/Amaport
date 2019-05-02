class CreateNgSellers < ActiveRecord::Migration[5.2]
  def change
    create_table :ng_sellers do |t|
      t.string :user_id
      t.string :seller_id

      t.timestamps
    end
  end
end
