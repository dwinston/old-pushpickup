class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :player_id

      t.timestamps
    end
    add_index :availabilities, :player_id
  end
end
