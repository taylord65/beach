class AddPidToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :pid, :string
  end
end
