class RemoveFieldNameFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :wepay_access_token
  end

  def down
    add_column :users, :wepay_access_token, :string
  end
end
