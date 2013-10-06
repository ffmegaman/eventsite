class AddEventNameToPins < ActiveRecord::Migration
  def change
    add_column :pins, :event_name, :string
    add_index :pins, :event_name
  end
end
