class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.timestamps

      t.integer :round, null: false, default: 1
    end
  end
end
