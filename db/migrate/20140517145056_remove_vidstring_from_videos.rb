class RemoveVidstringFromVideos < ActiveRecord::Migration
  def change
    remove_column :videos, :vidstring, :string
  end
end
