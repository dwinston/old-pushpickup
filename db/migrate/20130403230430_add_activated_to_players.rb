class AddActivatedToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :activated, :boolean, default: false
  end
end
