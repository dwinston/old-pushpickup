class ChangeDurationToMinutesAsIntegerInAvailabilities < ActiveRecord::Migration
  def change
    change_table :availabilities do |t|
      t.remove :duration
    end
    add_column :availabilities, :duration, :integer
  end
end
