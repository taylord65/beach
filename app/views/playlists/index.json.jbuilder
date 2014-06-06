json.array!(@playlists) do |playlist|
  json.extract! playlist, :id, :url, :title
  json.url playlist_url(playlist, format: :json)
end
