class AddCurrentVidIdToStream < ActiveRecord::Migration
  def change
    add_column :streams, :current_vid_id, :string
  end
end
