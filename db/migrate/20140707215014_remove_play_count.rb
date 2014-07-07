class RemovePlayCount < ActiveRecord::Migration
  def change
    remove_column :videos, :playcount, :integer
  end
end
