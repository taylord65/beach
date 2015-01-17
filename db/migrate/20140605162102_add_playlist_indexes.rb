class AddPlaylistIndexes < ActiveRecord::Migration
  def change
    add_reference :playlists, :stream, index: true
  end
end
