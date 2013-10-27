class DropFinanceTable < ActiveRecord::Migration
  def up
  	drop_table :finances
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
