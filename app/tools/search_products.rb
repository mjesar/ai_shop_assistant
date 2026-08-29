class SearchProducts < RubyLLM::Tool
  description "Search Shopify's global product catalog for items matching a query"
  param :query, desc: 'What the customer is looking for, e.g. "snowboard" or "red running shoes"'

  def execute(query:)
    token = fetch_shopify_catalog_token

    uri = URI('https://catalog.shopify.com/api/ucp/mcp')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['MCP-Protocol-Version'] = '2026-03-26'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{token}"

    request.body = {
      jsonrpc: '2.0',
      method: 'tools/call',
      id: 1,
      params: {
        name: 'search_catalog',
        arguments: {
          meta: {
            'ucp-agent': {
              profile: 'https://shopify.dev/ucp/agent-profiles/2026-04-08/valid-with-capabilities.json'
            }
          },
          catalog: {
            query: query,
            catalog_id: '01m179qyqpjnjj24wddcjqp2h6'
          }
        }
      }
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body.force_encoding('UTF-8'))

    products = data.dig('result', 'structuredContent', 'products') || []
    products.first(3).map do |p|
      { title: p['title'], price: p.dig('variants', 0, 'price'), url: p.dig('variants', 0, 'url') }
    end
  end
end
