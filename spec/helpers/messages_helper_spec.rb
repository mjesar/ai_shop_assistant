require 'rails_helper'

RSpec.describe MessagesHelper, type: :helper do
  describe '#render_markdown' do
    it 'converts bold markdown to HTML' do
      result = helper.render_markdown('**hello**')
      expect(result).to include('<strong>hello</strong>')
    end

    it 'converts markdown links to HTML with target blank' do
      result = helper.render_markdown('[Snowboard](https://example.com)')
      expect(result).to include('<a href="https://example.com"')
      expect(result).to include('target="_blank"')
    end
  end
end
