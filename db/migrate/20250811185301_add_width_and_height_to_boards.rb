class AddWidthAndHeightToBoards < ActiveRecord::Migration[8.0]
  def change
    add_column :boards, :width, :integer, null: false
    add_column :boards, :height, :integer, null: false
  end
end
