class AddStreamToVideo < ActiveRecord::Migration
  def change
    add_reference :videos, :stream, index: true
  end
end
