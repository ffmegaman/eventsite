class AddIndexToPaymentaccount < ActiveRecord::Migration
  def change
    add_index :paymentaccounts, :user_id
  end
end
