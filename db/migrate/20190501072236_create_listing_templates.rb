class CreateListingTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_templates do |t|
      t.string :user_id
      t.string :key
      t.text :caption
      t.text :value

      t.timestamps
    end
  end
end
