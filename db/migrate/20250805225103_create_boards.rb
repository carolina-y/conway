class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.timestamps

      t.integer :round, null: false, default: 0
      t.integer :width, null: false, default: 10
      t.integer :height, null: false, default: 10
    end
  end
end
