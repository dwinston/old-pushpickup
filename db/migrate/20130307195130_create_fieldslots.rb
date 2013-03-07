class CreateFieldslots < ActiveRecord::Migration
  def change
    create_table :fieldslots do |t|
      t.integer :availability_id
      t.integer :field_id
      t.boolean :open, default: true
      t.string :why_not_open

      t.timestamps
    end
    add_index :fieldslots, :open
  end
end
