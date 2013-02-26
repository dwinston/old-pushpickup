class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.string :full_address
      t.string :city
      t.text :notes

      t.timestamps
    end
  end
end
