class CreateNeeds < ActiveRecord::Migration
  def change
    create_table :needs do |t|
      t.string :name
      t.text :value
      t.integer :player_id

      t.timestamps
    end

    add_index :needs, :player_id
  end
end
