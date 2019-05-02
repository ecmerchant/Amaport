class CreateKeywordSets < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_sets do |t|
      t.string :user_id
      t.text :keyword
      t.text :brand_name
      t.text :manufacturer
      t.text :recommended_browse_nodes
      t.text :generic_keywords

      t.timestamps
    end
  end
end
