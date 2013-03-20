class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.datetime :start_time
      t.integer :duration
      t.integer :field_id

      t.timestamps
    end
  end
end
