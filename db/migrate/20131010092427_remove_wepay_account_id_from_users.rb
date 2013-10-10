class RemoveWepayAccountIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :wepay_account_id
  end

  def down
    add_column :users, :wepay_account_id, :integer
  end
end
