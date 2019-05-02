class CreateReplaceTables < ActiveRecord::Migration[5.2]
  def change
    create_table :replace_tables do |t|
      t.string :user_id
      t.text :from_keyword
      t.text :to_keyword

      t.timestamps
    end
  end
end
