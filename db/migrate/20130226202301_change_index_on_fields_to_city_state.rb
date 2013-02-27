class ChangeIndexOnFieldsToCityState < ActiveRecord::Migration
  def change
    remove_index :fields, :city
    add_index :fields, [:city, :state_abbr]
  end
end
