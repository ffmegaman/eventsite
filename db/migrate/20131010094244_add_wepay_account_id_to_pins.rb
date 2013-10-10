class AddWepayAccountIdToPins < ActiveRecord::Migration
  def change
    add_column :pins, :wepay_account_id, :integer
  end
end
