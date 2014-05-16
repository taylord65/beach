class RemoveFieldCurrentVidIdFromStreams < ActiveRecord::Migration
  def change
    remove_column :streams, :current_vid_id, :string
  end
end
