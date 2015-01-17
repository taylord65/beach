class AddCounterToStream < ActiveRecord::Migration
  def change
    add_column :streams, :counter, :time
  end
end
