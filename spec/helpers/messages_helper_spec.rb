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

    it 'renders an autolinked URL and a markdown image' do
      result = helper.render_markdown('https://example.com/x ![Board](https://example.com/a.png)')
      expect(result).to include('<a href="https://example.com/x"')
      expect(result).to include('<img src="https://example.com/a.png" alt="Board">')
    end

    context 'with untrusted content' do
      it 'escapes script tags' do
        result = helper.render_markdown('<script>alert(1)</script>')
        expect(result).not_to include('<script')
        expect(result).to include('&lt;script&gt;')
      end

      it 'escapes tags with event handlers' do
        result = helper.render_markdown('<img src=x onerror=alert(1)>')
        expect(result).not_to include('<img')
        expect(result).to include('&lt;img')
      end

      it 'escapes an event handler placed in image alt text' do
        result = helper.render_markdown('![x" onerror="alert(1)](https://example.com/a.png)')
        expect(result).to include('alt="x&quot; onerror=&quot;alert(1)"')
      end

      [
        '[click](javascript:alert(1))',
        '[click](JaVaScRiPt:alert(1))',
        '[click](java&#115;cript:alert(1))',
        '[click](vbscript:alert(1))',
        '[click](data:text/html,hello)'
      ].each do |markdown|
        it "does not create a link from #{markdown}" do
          expect(helper.render_markdown(markdown)).not_to include('<a ')
        end
      end

      it 'keeps comparison signs in normal text' do
        result = helper.render_markdown('boards under <100 and >50')
        expect(result).to include('under &lt;100 and &gt;50')
      end
    end
  end
end
