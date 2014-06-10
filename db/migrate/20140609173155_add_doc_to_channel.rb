class AddDocToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :doc, :string
  end
end
