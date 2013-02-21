class ChangeAvailabilities < ActiveRecord::Migration
  def change
    change_table :availabilities do |t|
      t.remove :end_time
      t.decimal :duration
    end
  end
end
