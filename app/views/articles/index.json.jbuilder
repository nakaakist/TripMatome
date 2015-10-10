json.array!(@articles) do |article|
  json.extract! article, :id, :title, :link
  json.url article_url(article, format: :json)
end
