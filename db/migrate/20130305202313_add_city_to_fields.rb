class AddCityToFields < ActiveRecord::Migration
  def change
    add_column :fields, :city_id, :integer
    remove_column :fields, :city
    remove_column :fields, :state_abbr
  end
end
