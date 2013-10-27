class DropPaymentTable < ActiveRecord::Migration
  def up
  	drop_table :payments
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
