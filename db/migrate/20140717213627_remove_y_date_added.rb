class RemoveYDateAdded < ActiveRecord::Migration
  def change
        remove_column :videos, :y_date_added, :string
  end
end
