class ChangeValueOfNeedsToString < ActiveRecord::Migration
  def change
    change_table :needs do |t|
      t.remove :value
      t.integer :value
    end
  end
end
