class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :user_id
      t.string :seller_id
      t.string :mws_auth_token
      t.string :aws_access_key_id
      t.string :secret_key

      t.timestamps
    end
  end
end
