class AddGmaps4railsColumnsToFields < ActiveRecord::Migration
  def change
    add_column :fields, :latitude, :float
    add_column :fields, :longitude, :float
    add_column :fields, :gmaps, :boolean
  end
end
