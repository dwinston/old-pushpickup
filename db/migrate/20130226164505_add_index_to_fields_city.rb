class AddIndexToFieldsCity < ActiveRecord::Migration
  def change
    add_index :fields, :city
  end
end
