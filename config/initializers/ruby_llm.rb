require 'net/http'
require 'json'

RubyLLM.configure do |config|
  config.gemini_api_key = ENV['GEMINI_API_KEY']
end

def fetch_shopify_catalog_token
  uri = URI('https://api.shopify.com/auth/access_token')
  response = Net::HTTP.post(
    uri,
    {
      client_id: ENV['SHOPIFY_CATALOG_CLIENT_ID'],
      client_secret: ENV['SHOPIFY_CATALOG_CLIENT_SECRET'],
      grant_type: 'client_credentials'
    }.to_json,
    'Content-Type' => 'application/json'
  )
  JSON.parse(response.body)['access_token']
end
