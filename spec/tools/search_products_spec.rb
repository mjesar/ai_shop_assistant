require 'rails_helper'

RSpec.describe SearchProducts do
  describe '#execute' do
    it 'returns product results from the catalog search' do
      tool = SearchProducts.new
      allow(tool).to receive(:fetch_shopify_catalog_token).and_return('fake_token')

      fake_body = {
        result: {
          structuredContent: {
            products: [
              {
                title: 'Test Snowboard',
                variants: [
                  { price: { amount: 55995, currency: 'USD' }, url: 'https://example.com/board' }
                ]
              }
            ]
          }
        }
      }.to_json

      fake_response = double('response', body: fake_body)
      allow_any_instance_of(Net::HTTP).to receive(:request).and_return(fake_response)

      result = tool.execute(query: 'snowboard')

      expect(result.first[:title]).to eq('Test Snowboard')
    end
  end
end
