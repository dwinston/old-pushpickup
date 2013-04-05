class AddSubscribedToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :subscribed, :boolean, default: false
  end
end
