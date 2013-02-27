class ChangeFieldTable < ActiveRecord::Migration
  def change
    change_table :fields do |t|
      t.remove :full_address
      t.string :street_address
      t.string :state_abbr
      t.string :zip_code
    end
  end
end
