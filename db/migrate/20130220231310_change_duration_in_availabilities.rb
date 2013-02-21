class ChangeDurationInAvailabilities < ActiveRecord::Migration
  def change
    change_table :availabilities do |t|
      t.remove :duration
    end
    add_column :availabilities, :duration, :decimal, :precision => 5, :scale => 2
  end
end
