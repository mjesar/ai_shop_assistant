require 'rails_helper'

RSpec.describe Chat, type: :model do
  it 'is valid with a model_id' do
    chat = Chat.new(model_id: 'gemini-2.0-flash')
    expect(chat).to be_valid
  end

  describe '#ask' do
    it 'saves the user message before calling the AI' do
      chat = Chat.create!(model_id: 'gemini-2.0-flash')

      fake_response = double(content: 'Hello there!')
      fake_llm_chat = double('RubyLLM::Chat', ask: fake_response)
      allow(RubyLLM).to receive(:chat).and_return(fake_llm_chat)

      chat.ask('Hi')

      expect(chat.messages.first.role).to eq('user')
      expect(chat.messages.first.content).to eq('Hi')
    end
  end
end
