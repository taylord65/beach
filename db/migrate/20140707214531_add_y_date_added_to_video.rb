class AddYDateAddedToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :y_date_added, :string
  end
end
