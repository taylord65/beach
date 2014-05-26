json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :title
  json.url subscription_url(subscription, format: :json)
end
