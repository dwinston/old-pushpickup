class AddActivateSentAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :activate_sent_at, :datetime
  end
end
