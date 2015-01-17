class AddVidstringToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :vidstring, :string
  end
end
