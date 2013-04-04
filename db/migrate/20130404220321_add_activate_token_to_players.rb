class AddActivateTokenToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :activate_token, :string
  end
end
