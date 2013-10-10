class AddWepayAccessTokenToPins < ActiveRecord::Migration
  def change
    add_column :pins, :wepay_access_token, :string
  end
end
