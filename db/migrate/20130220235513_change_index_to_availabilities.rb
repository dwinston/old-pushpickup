class ChangeIndexToAvailabilities < ActiveRecord::Migration
  def change
    remove_index :availabilities, column: :player_id
    add_index :availabilities, [:player_id, :start_time]
  end
end
