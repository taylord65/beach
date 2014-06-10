json.array!(@channels) do |channel|
  json.extract! channel, :id, :url, :title
  json.url channel_url(channel, format: :json)
end
