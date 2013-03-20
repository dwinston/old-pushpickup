class CreateGamePlayerJoinTable < ActiveRecord::Migration
  def change
    create_table :games_players, id: false do |t|
      t.integer :game_id
      t.integer :player_id
    end
  end
end
