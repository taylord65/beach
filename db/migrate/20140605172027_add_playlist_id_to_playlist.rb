class AddPlaylistIdToPlaylist < ActiveRecord::Migration
  def change
    add_column :playlists, :playlist_id, :string
  end
end
