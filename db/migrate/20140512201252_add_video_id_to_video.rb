class AddVideoIdToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :video_id, :string
  end
end
