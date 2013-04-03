class AddPasswordResetToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :password_reset_token, :string
    add_column :players, :password_reset_sent_at, :datetime
  end
end
