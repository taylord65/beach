class RemoveFieldCounterFromStreams < ActiveRecord::Migration
  def change
    remove_column :streams, :counter, :time
  end
end
