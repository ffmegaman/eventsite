class CreatePaymentaccounts < ActiveRecord::Migration
  def change
    create_table :paymentaccounts do |t|
      t.integer :user_id
      t.boolean :agreement
      t.string :wepay_access_token
      t.integer :wepay_account_id

      t.timestamps
    end
  end
end
