class AddEmailConfirmationToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :email_confirmation_token, :string
    add_column :players, :email_confirmation_sent_at, :datetime
    remove_column :players, :activate_token
    remove_column :players, :activate_sent_at
  end
end
