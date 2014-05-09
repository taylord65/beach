json.array!(@streams) do |stream|
  json.extract! stream, :id, :title, :description
  json.url stream_url(stream, format: :json)
end
