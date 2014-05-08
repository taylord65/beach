json.array!(@videos) do |video|
  json.extract! video, :id, :url, :name, :playcount, :length
  json.url video_url(video, format: :json)
end
